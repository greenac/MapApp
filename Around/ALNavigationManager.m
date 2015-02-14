//
//  ALNavigationManager.m
//  Banter!
//
//  Created by Andre Green on 1/10/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "ALNavigationManager.h"

@interface ALNavigationManager()

@property (nonatomic, assign) ALNavigationButton selectedButton;

@end



@implementation ALNavigationManager

+ (id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static ALNavigationManager *navManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        navManager = [[self alloc] init];
    });
    
    return navManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _selectedButton = ALNavigationButtonNone;
    }
    
    return self;
}

- (void)updateSelectedButton:(ALNavigationButton)selectedButton
{
    self.selectedButton = selectedButton;
}

- (ALNavigationButton)selectedNavigationButton
{
    return self.selectedButton;
}

@end
