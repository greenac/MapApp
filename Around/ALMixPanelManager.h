//
//  ALMixPanelManager.h
//  Banter!
//
//  Created by Andre Green on 11/2/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALEvent;

@interface ALMixPanelManager : NSObject

+ (id)manager;

- (void)sessionStarted;
- (void)sessionEnded;
- (void)eventShared:(ALEvent *)event from:(NSString *)fromLocation;
- (void)eventTapped:(ALEvent *)event;
- (void)registerForPushNotifications:(NSData *)deviceToken;

@end
