//
//  ALTutorialMainViewController.h
//  Banter!
//
//  Created by Andre Green on 10/6/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALTutorialMainViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *finishedTutorialButton;
@property (strong, nonatomic) UIButton *inviteFriendsButton;

@end
