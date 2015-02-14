//
//  ALMixPanelManager.m
//  Banter!
//
//  Created by Andre Green on 11/2/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALMixPanelManager.h"
#import "MixPanel.h"
#import "ALUserManager.h"
#import "ALUser.h"
#import "ALEvent.h"
#import "ALScene.h"

//#define kALMixPanelToken        @"4b3895376c3a9503aebb9dd568d91dcf" // development
#define kALMixPanelToken        @"0eb77540d7df6884c1d75e14e5481a42" // production
#define kALMixPanelSession      @"Session"
#define kALMixPanelEventShared  @"EventShared"
#define kALMixPanelEventTapped  @"EventTapped"

@interface ALMixPanelManager()

@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, assign) BOOL isSessionInProgress;

@end

@implementation ALMixPanelManager

+ (id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static ALMixPanelManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (id)init
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        _mixpanel = [Mixpanel sharedInstanceWithToken:kALMixPanelToken];
        _isSessionInProgress = NO;
    }
    
    return self;
}

+ (NSDateFormatter *)dateFormatter
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    
    return formatter;
}

- (NSString *)currentTimeAsString
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSDate *date = [NSDate date];
    [[ALMixPanelManager dateFormatter] setDateFormat:@"HH:mm:ss"];
    
    NSString *timeString = [[ALMixPanelManager dateFormatter] stringFromDate:date];
    
    return timeString;
}

- (NSString *)currentDateAsString
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSDate *date = [NSDate date];
    [[ALMixPanelManager dateFormatter] setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateString = [[ALMixPanelManager dateFormatter] stringFromDate:date];
    
    return dateString;
}

- (void)sessionStarted
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    ALUser *currentUser = [[ALUserManager manager] currentUser];
    
    if (currentUser && !self.isSessionInProgress) {
        NSDictionary *info = @{@"User":currentUser.email,
                               @"Day":[self currentDateAsString],
                               @"Time":[self currentTimeAsString]
                               };
        
        [self.mixpanel identify:currentUser.email];
        [self.mixpanel.people set:[self userInfoForUser:currentUser]];
        [self.mixpanel track:kALMixPanelSession properties:info];
        self.isSessionInProgress = YES;
    }
}

- (NSDictionary *)userInfoForUser:(ALUser *)user
{
    NSDictionary *info = @{@"username":user.email,
                           @"first_name":user.firstName,
                           @"last_name":user.lastName,
                           @"email":user.email
                           };
    return info;
}

- (void)sessionEnded
{
    self.isSessionInProgress = NO;
}

- (void)eventShared:(ALEvent *)event from:(NSString *)fromLocation
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    ALUser *currentUser = [[ALUserManager manager] currentUser];
    NSDictionary *info = @{@"User":currentUser.email,
                           @"Event":event.scene.name,
                           @"Type":event.type,
                           @"Time":[self currentTimeAsString],
                           @"From":fromLocation
                           };
    
    [self.mixpanel track:kALMixPanelEventShared properties:info];
}

- (void)eventTapped:(ALEvent *)event
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    ALUser *currentUser = [[ALUserManager manager] currentUser];
    NSDictionary *info = @{@"User":currentUser.email,
                           @"Event":event.scene.name,
                           @"Type":event.type,
                           @"OnGoing":@(event.isOngoing),
                           @"ComingUp":@(event.isUpcoming)
                           };
    
    [self.mixpanel track:kALMixPanelEventTapped properties:info];
}

- (void)registerForPushNotifications:(NSData *)deviceToken
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ALUser *currentUser = [ALUserManager.manager currentUser];
    if (currentUser) {
        [self.mixpanel identify:currentUser.email];
        [self.mixpanel.people addPushDeviceToken:deviceToken];
    }
}

@end
