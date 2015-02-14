//
//  ALMapManager.h
//  Around
//
//  Created by Andre Green on 9/1/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <MapKit/MapKit.h>

#define kALMapManagerEvent                  @"event"
#define kALMapManagerAnnotation             @"annotation"
#define kALMapManagerAnnotationsToAdd       @"kALMapManagerAnnotationsToAdd"
#define kALMapManagerAnnotationsToRemove    @"kALMapManagerAnnotationsToRemove"

@class ALScene, ALEvent;

@interface ALMapManager : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableArray *annotationsToRemove;
@property (nonatomic, strong) NSMutableArray *annotationsToAdd;
@property (nonatomic, assign) MKMapRect visibleRect;
@property (nonatomic, strong) NSArray *sortPropertyNames;


+ (id)manager;
- (void)getAnnotationsForUser;
- (void)checkIfUsersCityIsSupported:(CLLocationCoordinate2D)currentLocation;
- (void)updateFilterOptionsForType:(NSString *)eventType show:(BOOL)shouldShow;
- (void)updateUserLocation:(CLLocationCoordinate2D)userLocation;
- (void)updateOccupancy;
- (void)updateEvents;
- (void)retrieveFilterOrder;
- (NSArray *)visibleAnnotations;
- (NSArray *)annotationsWithIds:(NSArray *)eventIds;
- (NSArray *)visibleAnnotationsInMapRect:(MKMapRect)mapRect;
- (NSArray *)eventFilterOrder;
- (void)changeFilterStateForEventName:(NSString *)eventName;
- (BOOL)isEventNameFiltered:(NSString *)eventName;
- (void)oppeningMessageWithCompletion:(void(^)(NSDictionary *responseDict))completion;
@end
