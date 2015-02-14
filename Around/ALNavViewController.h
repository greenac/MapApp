//
//  ALNavViewController.h
//  Banter!
//
//  Created by Andre Green on 1/13/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALNavViewController : UIViewController


- (void)moreButtonPushed:(id)sender;
- (void)filterButtonPushed:(id)sender;
- (void)eventListButtonPushed:(id)sender;

@property (nonatomic, strong) UIBarButtonItem *moreBarButton;
@property (nonatomic, strong) UIBarButtonItem *filterBarButton;
@property (nonatomic, strong) UIButton *eventListButton;

@end
