//
//  ALEvent.m
//  Around
//
//  Created by Andre Green on 9/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALEvent.h"
#import "ALAddress.h"
#import "ALHours.h"
#import "ALScene.h"

@interface ALEvent()

@end

@implementation ALEvent

- (id)initWithDictionary:(NSDictionary *)eventDict
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        _scene              = [[ALScene alloc] initWithDictionary:eventDict[@"scene"]];
        _address            = [[ALAddress alloc] initWithDictionary:eventDict];
        _hours              = [[ALHours alloc] initWithDictionary:eventDict];
        _day                = eventDict[@"day"];
        _month              = eventDict[@"month"];
        _year               = eventDict[@"year"];
        _description1       = eventDict[@"description1"];
        _description2       = eventDict[@"description2"];
        _start              = eventDict[@"start"];
        _end                = eventDict[@"end"];
        _message            = eventDict[@"message"];
        _type               = eventDict[@"type"];
        _typeExt            = [self parseTypeExt:eventDict[@"type_ext"]];
        _distanceToUser     = eventDict[@"distance_to_user"];
        _eventId            = eventDict[@"event_id"];
        _status             = [self parseEventStatus:eventDict];
        _startDate          = [self dateFromString:eventDict[@"start_date"]];
        _endDate            = [self dateFromString:eventDict[@"end_date"]];
    }

    return self;
}

+ (NSDateFormatter *)dateFormatter
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    
    return formatter;
}

- (NSNumber *)parseTypeExt:(NSString *)typeExt
{
    return @(typeExt.intValue);
}

- (NSString *)hoursForToday
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSString *hasHoursString = [self.hours hoursForCurrentDay];
    NSNumber *hasHours = [NSNumber numberWithInteger:hasHoursString.integerValue];
    if (hasHours.boolValue || (self.year && self.month && self.day)) {
        return [NSString stringWithFormat:@"%@ - %@", self.start, self.end];
    } else {
        return [self.scene.hours hoursForCurrentDay];
    }
    return NSLocalizedString(@"No Times For This Event", nil);
}

- (ALEventStatus)parseEventStatus:(NSDictionary *)eventDict
{
    NSNumber *isUpcoming = eventDict[@"is_upcoming"];
    if (isUpcoming.boolValue) {
        return ALEventStatusUpcoming;
    }
    return ALEventStatusOngoing;
}

- (NSString *)parseEventType
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSArray *comps = [self.type componentsSeparatedByString:@"_"];
    NSMutableString *readableType = [NSMutableString new];
    
    BOOL firstWord = YES;
    for (NSString *word in comps) {
        NSString *firstLetter = [NSString stringWithFormat:@"%c", [word characterAtIndex:0]];
        NSString *newWord = [word stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLetter.uppercaseString];
        
        if (firstWord) {
            [readableType appendString:newWord];
        } else {
            [readableType appendString:[NSString stringWithFormat:@" %@", newWord]];
        }
        
        firstWord = NO;
    }
    
    return readableType;
}

- (BOOL)isEqualToEvent:(ALEvent *)event
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (![self.scene.name isEqualToString:event.scene.name]) {
        return NO;
    } else if (![self.start isEqualToString:event.start]) {
        return NO;
    } else if (![self.end isEqualToString:event.end]) {
        return NO;
    } else if (![self.type isEqualToString:event.type]){
        return NO;
    } else if (![self.address isEqualToAddress:event.address]) {
        return NO;
    }
    
    return YES;
}

- (NSDate *)dateFromString:(NSString *)dateString
{
    return [[ALEvent dateFormatter] dateFromString:dateString];
}

- (BOOL)isOngoing
{
    return self.status == ALEventStatusOngoing;
}

- (BOOL)isUpcoming
{
    return self.status == ALEventStatusUpcoming;
}
@end
