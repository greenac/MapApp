//
//  ALMapManager.m
//  Around
//
//  Created by Andre Green on 9/1/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALMapManager.h"
#import "ALUrls.h"
#import "ALComment.h"
#import "ALScene.h"
#import "ALEvent.h"
#import "ALUserManager.h"
#import "ALUser.h"
#import "ALMapAnnotation.h"
#import "ALAddress.h"
#import "ALNotifications.h"
#import "Responses.h"

#import <math.h>



#define kALMapManagerTimeOut            60
#define kALMapManagerExpiredEvents      @"expired_events"
#define kALMapManagerNewEvents          @"events"
#define kALMapManagerDayTimeShift       @"day_time_shift"
#define kALMapManagerFilterOrder        @"filter_order"



@interface ALMapManager()

@property (nonatomic, strong) NSMutableDictionary *annotations;

/*
// annotations passed from map. these are the annotations that are currently
// visible on map
*/

@property (nonatomic, strong) NSArray *filterOrder;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, assign) BOOL isFetchingEvents;
@property (nonatomic, strong) NSMutableDictionary *filters;


@end

@implementation ALMapManager

+ (id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static ALMapManager *mapManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapManager = [[self alloc] init];
    });
    
    return mapManager;
}

- (NSMutableDictionary *)annotations
{
    if (!_annotations) {
        _annotations = [NSMutableDictionary new];
    }
    
    return _annotations;
}

- (NSMutableArray *)annotationsToAdd
{
    if (!_annotationsToAdd) {
        _annotationsToAdd = [NSMutableArray new];
    }
    
    return _annotationsToAdd;
}

- (NSMutableArray *)annotationsToRemove
{
    if (!_annotationsToRemove) {
        _annotationsToRemove = [NSMutableArray new];
    }
    
    return _annotationsToRemove;
}

- (NSMutableDictionary *)filters
{
    if (!_filters) {
        _filters = [NSMutableDictionary new];
    }
    return _filters;
}

- (NSArray *)annotationsNotFiltered
{
    NSMutableArray *notFiltered = [NSMutableArray new];
    for (ALMapAnnotation *annotation in self.annotations.allValues) {
        if ([annotation.event.type isEqualToString:@"occupancy"] &&
            (annotation.event.typeExt.intValue == 0 ||
            annotation.event.status == ALEventStatusUpcoming)) {
                NSLog(@"occupancy event that is upcoming or has type_ext = 0");
        } else {
            NSString *eventName = [self eventName:annotation.event];
            [self.filters enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSNumber *isFiltered, BOOL *stop) {
                if ([eventName isEqualToString:name] && !isFiltered.boolValue) {
                    [notFiltered addObject:annotation];
                    *stop = YES;
                }
            }];
        }
    }
    
    return notFiltered;
}

- (void)getAnnotationsForUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self fetchEventsAndAnnotationsForUserPosition:self.userLocation];
}

- (void)checkIfUsersCityIsSupported:(CLLocationCoordinate2D)currentLocation
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self checkWithServerIfUsersCityIsSupported:currentLocation];
}

- (void)serverReturnedInfoAboutSupportedCity:(BOOL)isSupported
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] postNotificationName:kALNotificationMapManagerUserLocationSupported
                                                        object:self
                                                      userInfo:@{kALNotificationMapManagerUserLocationSupported:@(isSupported)}];
                                                            
}

- (void)sendOutEventsUpdatedNotification
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] postNotificationName:kALNotificationMapManagerUpdatedAnnotations
                                                        object:nil];
}

- (void)retrieveFilterOrder
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self retrieveFilterOrderWithCompletion:^(NSDictionary *responseDict) {
            if (responseDict[@"filter_order"]) {
                self.filterOrder = responseDict[@"filter_order"];
                [self fillFilters];
            }
        }];
    });
}

- (void)fillFilters
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    for (NSArray *filterArray in self.filterOrder) {
        for (NSString *filterName in filterArray) {
            [self.filters setObject:@(NO) forKey:filterName];
        }
    }
}

- (void)changeFilterStateForEventName:(NSString *)eventName
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (self.filters[eventName]) {
        NSNumber *isFilteredNumber = self.filters[eventName];
        BOOL newFilterState = !isFilteredNumber.boolValue;
        self.filters[eventName] = @(newFilterState);
        
        [self filterAnnotationsByEventName:eventName shouldFilter:newFilterState];
        
        [self sendOutEventsUpdatedNotification];
    }
}

- (BOOL)isEventNameFiltered:(NSString *)eventName
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    BOOL isFiltered = NO;
    if (self.filters[eventName]) {
        NSNumber *filteredNumber = self.filters[eventName];
        isFiltered = filteredNumber.boolValue;
    }
    
    return isFiltered;
}

- (BOOL)isEventFiltered:(ALEvent *)event
{
    return [self isEventNameFiltered:[self eventName:event]];
}

- (NSString *)eventName:(ALEvent *)event
{
    if (event.typeExt.intValue == 0) {
        return event.type;
    }
    
    return [event.type stringByAppendingString:event.typeExt.stringValue];
}

- (void)fetchEventsAndAnnotationsForUserPosition:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self sendRequestWithUrlString:[NSString stringWithFormat:@"%@%@", SERVER_URL, FETCH_EVENTS_URL]
                      userLocation:coordinate
               withCurrentEventIds:self.annotations.allKeys
                forOccupancyUpdate:NO];
}

- (void)updateOccupancy
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!self.isFetchingEvents) {
        [self sendRequestWithUrlString:[NSString stringWithFormat:@"%@%@", SERVER_URL, FETCH_EVENTS_URL]
                          userLocation:self.userLocation
                   withCurrentEventIds:self.annotations.allKeys
                    forOccupancyUpdate:YES];
    }
}

- (void)doneLoadingEventsFromServer:(NSDictionary *)results
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSArray *newEvents = results[kALMapManagerNewEvents];
    self.filterOrder = results[kALMapManagerFilterOrder];
    [self addNewEventsAndAnnotations:newEvents];
}

- (void)addNewEventsAndAnnotations:(NSArray *)newEventsAsDictionaries
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self.annotationsToRemove removeAllObjects];
    [self.annotationsToAdd removeAllObjects];
    
    for (NSDictionary *eventDictionary in newEventsAsDictionaries) {
        ALEvent *event = [[ALEvent alloc] initWithDictionary:eventDictionary];
        ALMapAnnotation *annotation = [[ALMapAnnotation alloc] initWithEvent:event];
        [self.annotations setObject:annotation forKey:event.eventId];
    
        // going to do something that hurts my life...fucking stupid
        if (![self isEventFiltered:event]) {
            if (([event.type isEqualToString:@"occupancy"] && event.status == ALEventStatusUpcoming)) {
                NSLog(@"upcoming occupancy event...not showing");
            } else {
                [self.annotationsToAdd addObject:annotation];
            }
        }        
    }
    
    [self finishedProcessingAnnotations];
}

- (void)filterAnnotationsByEventName:(NSString *)eventName shouldFilter:(BOOL)shouldFilter
{
    [self.annotationsToAdd removeAllObjects];
    [self.annotationsToRemove removeAllObjects];
    
    for (ALMapAnnotation *annotation in self.annotations.allValues) {
        if ([[self eventName:annotation.event] isEqualToString:eventName]) {
            if (shouldFilter) {
                [self.annotationsToRemove addObject:annotation];
            } else {
                [self.annotationsToAdd addObject:annotation];
            }
        }
    }
}

- (void)finishedProcessingAnnotations
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kALNotificationMapManagerUpdatedAnnotations
                                                        object:self
                                                      userInfo:nil];
}

- (NSArray *)annotationsSortedByDistance
{
    NSArray *visAnnotations = [self annotationsNotFiltered];
    NSArray *sortedAnnotations = [visAnnotations sortedArrayUsingComparator:^NSComparisonResult(ALMapAnnotation *a1, ALMapAnnotation *a2) {
        return [a1.event.distanceToUser compare:a2.event.distanceToUser];
    }];
    
    return sortedAnnotations;
}

- (void)removeAnnotationsAndGetAnnotationsToRemoveWithIds:(NSArray *)pastEventsIds
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.annotationsToRemove removeAllObjects];
    
    for (NSNumber *eventId in pastEventsIds) {
        if (self.annotations[eventId]) {
            ALMapAnnotation *annotation = self.annotations[eventId];
            [self.annotationsToRemove addObject:annotation];
            [self.annotations removeObjectForKey:eventId];
        }
    }
}

- (ALEvent *)getEventWithEventId:(NSNumber *)eventId
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ALMapAnnotation *annotation = self.annotations[eventId];
    return annotation.event;
}

- (ALMapAnnotation *)getAnnotationWithEventId:(NSNumber *)eventId
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return self.annotations[eventId];
}

- (NSArray *)annotationsOfType:(NSString *)type fromAnnotations:(NSArray *)annotations
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableArray *annotationsOfType = [NSMutableArray new];
    for (ALMapAnnotation *annotation in annotations) {
        if ([annotation.event.type isEqualToString:type]) {
            [annotationsOfType addObject:annotation];
        }
    }
    
    return annotationsOfType;
}

- (NSArray *)annotationsWithIds:(NSArray *)eventIds
{
    NSMutableArray *annotations = [NSMutableArray new];
    for (NSNumber *eventId in eventIds) {
        if (self.annotations[eventId]) {
            [annotations addObject:self.annotations[eventId]];
        }
    }
    return annotations;
}

- (BOOL)annotation:(ALMapAnnotation *)annotation inMapRect:(MKMapRect)mapRect
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
    return MKMapRectContainsPoint(mapRect, annotationPoint);
}

- (NSArray *)visibleAnnotations
{
    return [self visibleAnnotationsInMapRect:self.visibleRect];
}

- (NSArray *)visibleAnnotationsInMapRect:(MKMapRect)mapRect
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSMutableArray *visibleAnnotations = [NSMutableArray new];
    
    NSArray *unfilteredAnnotations = [self annotationsNotFiltered];
    
    for (ALMapAnnotation *annotation in unfilteredAnnotations) {
        if ([self annotation:annotation inMapRect:mapRect]) {
            [visibleAnnotations addObject:annotation];
        }
    }
    
    [visibleAnnotations sortUsingComparator:^NSComparisonResult(ALMapAnnotation *a1, ALMapAnnotation *a2) {
        return [a1.event.distanceToUser compare:a2.event.distanceToUser];
    }];
    
    return visibleAnnotations;
}

- (NSArray *)eventIdsFromAnnotations:(NSArray *)annotations
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableArray *ids = [NSMutableArray new];
    for (ALMapAnnotation *annotation in annotations) {
        [ids addObject:annotation.event.eventId];
    }
    
    return ids;
}

- (NSArray *)eventFilterOrder
{
    return self.filterOrder;
}

- (void)updateEvents
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (!self.isFetchingEvents) {
        NSDate *now = [NSDate date];
        
        [self.annotationsToRemove removeAllObjects];
        [self.annotationsToAdd removeAllObjects];
        
        NSArray *visibleAnnotations = [self annotationsNotFiltered];
        NSSet *visibleIds = [NSSet setWithArray:[self eventIdsFromAnnotations:visibleAnnotations]];
        
        for (ALMapAnnotation *annotation in self.annotations.allValues) {
            ALEvent *event = annotation.event;
            if (![self isEventFiltered:event]) {
                // set the event status
                if ([event.endDate compare:now] == NSOrderedAscending) {
                    event.status = ALEventStatusOver;
                    if ([visibleIds containsObject:event.eventId]) {
                        // add event id to events to remove. will have to send to method to update listners
                        [self.annotationsToRemove addObject:annotation];
                    }
                } else if ([event.startDate compare:now] == NSOrderedAscending && event.status != ALEventStatusOngoing) {
                    event.status = ALEventStatusOngoing;
                    [self.annotationsToAdd addObject:annotation];
                    [self.annotationsToRemove addObject:annotation];
                } else if ([event.startDate compare:now] == NSOrderedDescending && event.status != ALEventStatusUpcoming){
                    event.status = ALEventStatusUpcoming;
                    [self.annotationsToAdd addObject:annotation];
                    [self.annotationsToRemove addObject:annotation];
                }
                
                event.distanceToUser = [self distanceToUserFromLocation:event.address.location];
            }
        }
        
        [self finishedProcessingAnnotations];
    }
}

- (void)updateUserLocation:(CLLocationCoordinate2D)userLocation
{
    self.userLocation = userLocation;
}

- (NSNumber *)distanceToUserFromLocation:(CLLocationCoordinate2D)location
{
    static CGFloat earthRadius = 6371009.0;
    static CGFloat degreesToRadians = M_PI/180.0;
    
    CGFloat latitude1 = self.userLocation.latitude*degreesToRadians;
    CGFloat latitude2 = location.latitude*degreesToRadians;
    CGFloat dLatitude = latitude1 - latitude2;
    CGFloat dLongitude = (self.userLocation.longitude - location.longitude)*degreesToRadians;
    CGFloat k = pow(sin(.5*dLatitude), 2.0) + cos(latitude1)*cos(latitude2)*pow(sin(.5*dLongitude), 2.0);
    CGFloat d = 2.0*earthRadius*asin(sqrt(k));
    return @(d);
}

- (void)oppeningMessageWithCompletion:(void(^)(NSDictionary *responseDict))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self getOppeningMessageWithCompletion:completion];
    });
}

- (void)sendRequestWithUrlString:(NSString*)urlString
                    userLocation:(CLLocationCoordinate2D)coordinate
             withCurrentEventIds:(NSArray *)currentEvents
              forOccupancyUpdate:(BOOL)forOccupancy
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (!self.isFetchingEvents) {
        self.isFetchingEvents = YES;
        
        NSError *error;
        NSDictionary *userInfo = @{@"latitude":@(coordinate.latitude),
                                   @"longitude":@(coordinate.longitude),
                                   @"event_ids":currentEvents,
                                   @"for_occupancy":@(forOccupancy)
                                   };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"applcations/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
        [request setTimeoutInterval:kALMapManagerTimeOut];
        
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                   fromData:jsonData
                                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                              NSLog(@"response url %@, encoding %@", response.URL, response.textEncodingName);
                                                              NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                              self.isFetchingEvents = NO;
                                                              if (error) {
                                                                  NSLog(@"error loading json %@", [error userInfo]);
                                                                  return;
                                                              } else {
                                                                  [self doneLoadingEventsFromServer:payload];
                                                              }
                                                          }];
        [uploadTask resume];
    }
    
}

- (void)checkWithServerIfUsersCityIsSupported:(CLLocationCoordinate2D)currentLocation
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSError *error;
    NSDictionary *userPoint = @{@"latitude":@(currentLocation.latitude),
                                @"longitude":@(currentLocation.longitude)};
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userPoint options:0 error:&error];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, CITY_SUPPORTED];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"applcations/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:kALMapManagerTimeOut];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:jsonData
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSLog(@"response url %@, encoding %@", response.URL, response.textEncodingName);
                                                          NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                          
                                                          if (error) {
                                                              NSLog(@"error loading json %@", [error userInfo]);
                                                              return;
                                                          }
                                                          
                                                          NSNumber *responseNumber = responseDict[@"response"];
                                                          NSLog(@"supported city response: %@", responseNumber);
                                                          BOOL inRegion = NO;
                                                          if (responseNumber.integerValue == kALMapManagerCitySupported) {
                                                              inRegion = YES;
                                                          }
                                                          
                                                          [self serverReturnedInfoAboutSupportedCity:inRegion];
                                                      }];
    [uploadTask resume];
}

- (void)retrieveFilterOrderWithCompletion:(void(^)(NSDictionary *responseDict))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, FILTER_ORDER];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:kALMapManagerTimeOut];
    
    NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        NSLog(@"response url %@, encoding %@", response.URL, response.textEncodingName);
                                                        if (error) {
                                                            NSLog(@"Error retrieving filter order: %@", error.localizedDescription);
                                                            completion(nil);
                                                            return;
                                                        } else {
                                                            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                            if (error) {
                                                                NSLog(@"Error decoding JSON while retrieving filter order: %@", error.localizedDescription);
                                                                completion(nil);
                                                                return;
                                                            } else {
                                                                NSNumber *responseNumber = responseDict[@"response"];
                                                                if (responseNumber.intValue == KALResponseSuccess) {
                                                                    completion(responseDict);
                                                                } else {
                                                                    NSLog(@"Error from server retrieving filter order: %@", error.localizedDescription);
                                                                    completion(responseDict);
                                                                }
                                                            }
                                                        }
                                                    }];
    [downloadTask resume];
}

- (void)getOppeningMessageWithCompletion:(void(^)(NSDictionary *responseDict))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, OPPENING_MESSAGE];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:kALMapManagerTimeOut];
    
    NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        NSLog(@"response url %@, encoding %@", response.URL, response.textEncodingName);
                                                        if (error) {
                                                            NSLog(@"Error retrieving filter order: %@", error.localizedDescription);
                                                            completion(nil);
                                                            return;
                                                        } else {
                                                            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                            if (error) {
                                                                NSLog(@"Error decoding JSON while retrieving oppening message %@", error.localizedDescription);
                                                                completion(nil);
                                                                return;
                                                            } else {
                                                                NSNumber *responseNumber = responseDict[@"response"];
                                                                if (responseNumber.intValue == KALResponseSuccess) {
                                                                    completion(responseDict);
                                                                } else {
                                                                    NSLog(@"Error from server retrieving filter order: %@", error.localizedDescription);
                                                                    completion(responseDict);
                                                                }
                                                            }
                                                        }
                                                    }];
    [downloadTask resume];
}
@end
