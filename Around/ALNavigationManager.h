//
//  ALNavigationManager.h
//  Banter!
//
//  Created by Andre Green on 1/10/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALNavigationItem;

typedef NS_ENUM(NSUInteger, ALNavigationButton) {
    ALNavigationButtonNone,
    ALNavigationButtonMore,
    ALNavigationButtonEventList,
    ALNavigationButtonFilter,
};

@interface ALNavigationManager : NSObject


+ (id)manager;
- (void)updateSelectedButton:(ALNavigationButton)selectedButton;
- (ALNavigationButton)selectedNavigationButton;

@end
