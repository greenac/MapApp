//
//  ALEvent.h
//  Around
//
//  Created by Andre Green on 9/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALHours, ALAddress, ALScene;


typedef NS_ENUM(NSUInteger, ALEventStatus) {
    ALEventStatusUpcoming = 0,
    ALEventStatusOngoing,
    ALEventStatusOver
};


@interface ALEvent : NSObject

@property (nonatomic, strong) ALAddress *address;
@property (nonatomic, strong) ALHours *hours;
@property (nonatomic, strong) NSNumber *day;
@property (nonatomic, strong) NSNumber *month;
@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, copy) NSString *description1;
@property (nonatomic, copy) NSString *description2;
@property (nonatomic, copy) NSString *start;
@property (nonatomic, copy) NSString *end;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *typeExt;
@property (nonatomic, copy) NSNumber *distanceToUser;
@property (nonatomic, copy) NSNumber *eventId;
@property (nonatomic, strong)NSDate *startDate;
@property (nonatomic, strong)NSDate *endDate;
@property (nonatomic, strong) ALScene *scene;
@property (nonatomic, assign) ALEventStatus status;

- (id)initWithDictionary:(NSDictionary*)eventDict;
- (NSString *)hoursForToday;
- (NSString *)parseEventType;
- (BOOL)isEqualToEvent:(ALEvent *)event;
- (BOOL)isOngoing;
- (BOOL)isUpcoming;

@end
