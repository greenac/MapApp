//
//  ALTutorialMainViewController.m
//  Banter!
//
//  Created by Andre Green on 10/6/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALTutorialMainViewController.h"
#import "ALTutorialViewController.h"
#import "ALUserDefaults.h"
#import "ALSegues.h"
#import "ALUserManager.h"
#import "ALUser.h"
#import "ALFaceBookFriendsViewController.h"
#import "ALInviteFriendsViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kALColorBanterGreen [UIColor colorWithRed:3.0f/255.0f green:177.0f/255.0f blue:146.0f/255.0f alpha:1.0f]

@interface ALTutorialMainViewController ()

@property (nonatomic, strong) NSArray *tutorialViewControllers;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL showFacebookFriends;

@end

@implementation ALTutorialMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ALTutorialViewController *tutorialController1 = [ALTutorialViewController new];
    UIImage *background1 = [UIImage imageNamed:@"tutorial-01"];
    tutorialController1.backgroundImage = background1;
    tutorialController1.pageIndex = 0;
    
    ALTutorialViewController *tutorialController2 = [ALTutorialViewController new];
    UIImage *background2 = [UIImage imageNamed:@"tutorial-02"];
    tutorialController2.backgroundImage = background2;
    tutorialController2.pageIndex = 1;
    
    ALTutorialViewController *tutorialController3 = [ALTutorialViewController new];
    UIImage *background3 = [UIImage imageNamed:@"tutorial-03"];
    tutorialController3.backgroundImage = background3;
    tutorialController3.pageIndex = 2;
    
    ALTutorialViewController *tutorialController4 = [ALTutorialViewController new];
    UIImage *background4 = [UIImage imageNamed:@"tutorial-04"];
    tutorialController4.backgroundImage = background4;
    tutorialController4.pageIndex = 3;

    
    ALUser *currentUser = [[ALUserManager manager] currentUser];
    self.showFacebookFriends = currentUser.friends.allObjects.count > 0;
    if (self.showFacebookFriends) {
        ALFaceBookFriendsViewController *tutorialController5 = [[ALFaceBookFriendsViewController alloc] initWithNibName:nil bundle:nil];
        tutorialController5.pageIndex = 4;
        tutorialController5.fromTutorial = YES;
        
        self.tutorialViewControllers = @[tutorialController1,
                                         tutorialController2,
                                         tutorialController3,
                                         tutorialController4,
                                         tutorialController5];
    } else {
        self.tutorialViewControllers = @[tutorialController1,
                                         tutorialController2,
                                         tutorialController3,
                                         tutorialController4];
    }
    
    
    self.currentIndex = 0;
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                             options:nil];
    
    [self.pageViewController setViewControllers:@[self.tutorialViewControllers[self.currentIndex]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    self.pageViewController.view.frame = self.view.bounds;
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:205.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
    self.pageControl.currentPageIndicatorTintColor = kALColorBanterGreen;
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = self.tutorialViewControllers.count;
    [self.pageControl updateCurrentPageDisplay];
    
    [self.view bringSubviewToFront:self.pageControl];
    
    CGRect buttonRect = CGRectMake(0.0f, 0.0f, 140.0f, 25.0f);
    
    self.finishedTutorialButton = [[UIButton alloc] initWithFrame:buttonRect];
    [self.finishedTutorialButton addTarget:self
                                    action:@selector(finishedTutorialButtonPressed:)
                          forControlEvents:UIControlEventTouchDown];
    self.finishedTutorialButton.backgroundColor = kALColorBanterGreen;
    [self.finishedTutorialButton setTitle:NSLocalizedString(@"Let's Banter!", nil) forState:UIControlStateNormal];
    [self.finishedTutorialButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.finishedTutorialButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    self.finishedTutorialButton.clipsToBounds = YES;
    self.finishedTutorialButton.layer.cornerRadius = 2.0f;
    self.finishedTutorialButton.hidden = YES;
    [self.view addSubview:self.finishedTutorialButton];
    
    if (self.showFacebookFriends) {
        self.inviteFriendsButton = [[UIButton alloc] initWithFrame:buttonRect];
        [self.inviteFriendsButton addTarget:self
                                     action:@selector(inviteFriendsButtonPressed:)
                           forControlEvents:UIControlEventTouchDown];
        self.inviteFriendsButton.backgroundColor = kALColorBanterGreen;
        [self.inviteFriendsButton setTitle:NSLocalizedString(@"Invite More Friends", nil) forState:UIControlStateNormal];
        [self.inviteFriendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.inviteFriendsButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        self.inviteFriendsButton.clipsToBounds = YES;
        self.inviteFriendsButton.layer.cornerRadius = 2.0f;
        self.inviteFriendsButton.hidden = YES;
        [self.view addSubview:self.inviteFriendsButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    static CGFloat xPadding = 10.0f;
    static CGFloat yPadding = 35.0f;
    
    CGRect finishedButtonRect = CGRectMake(0.5f*(self.view.bounds.size.width - self.finishedTutorialButton.bounds.size.width),
                                           self.view.bounds.size.height - self.finishedTutorialButton.bounds.size.height - yPadding,
                                           self.finishedTutorialButton.bounds.size.width,
                                           self.finishedTutorialButton.bounds.size.height);
    
    if (self.showFacebookFriends) {
        self.inviteFriendsButton.frame = CGRectMake(xPadding,
                                                    self.view.bounds.size.height - self.inviteFriendsButton.frame.size.height - yPadding,
                                                    self.inviteFriendsButton.frame.size.width,
                                                    self.inviteFriendsButton.frame.size.height);
        
        finishedButtonRect = CGRectMake(self.view.bounds.size.width - self.finishedTutorialButton.frame.size.width - xPadding,
                                        self.view.bounds.size.height - self.finishedTutorialButton.bounds.size.height - yPadding,
                                        self.finishedTutorialButton.bounds.size.width,
                                        self.finishedTutorialButton.bounds.size.height);
    }
    
    self.finishedTutorialButton.frame = finishedButtonRect;
}

#pragma mark page view controller data souce methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    ALTutorialViewController *tutorialController = (ALTutorialViewController *)viewController;
    NSUInteger nextPageIndex = tutorialController.pageIndex + 1;
    if (nextPageIndex >= self.tutorialViewControllers.count) {
        return nil;
    }
    
    return self.tutorialViewControllers[nextPageIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    ALTutorialViewController *tutorialController = (ALTutorialViewController *)viewController;
    NSInteger previousPageIndex = tutorialController.pageIndex - 1;
    if (previousPageIndex < 0) {
        return nil;
    }
    
    return self.tutorialViewControllers[previousPageIndex];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.tutorialViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    UIViewController *tutorialViewController = [pendingViewControllers firstObject];
    NSUInteger pageIndex = NSUIntegerMax;
    if ([tutorialViewController isMemberOfClass:[ALTutorialViewController class]]) {
        ALTutorialViewController *tvc = (ALTutorialViewController *)tutorialViewController;
        pageIndex = tvc.pageIndex;
    } else if ([tutorialViewController isMemberOfClass:[ALFaceBookFriendsViewController class]]) {
        ALFaceBookFriendsViewController *ffvc = (ALFaceBookFriendsViewController *)tutorialViewController;
        pageIndex = ffvc.pageIndex;
    }
    
    self.currentIndex = pageIndex;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    self.pageControl.currentPage = self.currentIndex;
    [self.pageControl updateCurrentPageDisplay];
    
    if (self.currentIndex == self.tutorialViewControllers.count - 1) {
        self.finishedTutorialButton.alpha = 0.0f;
        self.finishedTutorialButton.hidden = NO;
        self.inviteFriendsButton.alpha = 0.0f;
        self.inviteFriendsButton.hidden = NO;
        [self.view bringSubviewToFront:self.finishedTutorialButton];
        [UIView animateWithDuration:.25 animations:^{
            self.finishedTutorialButton.alpha = 1.0f;
            self.inviteFriendsButton.alpha = 1.0f;
        }];
    } else {
        if (!self.finishedTutorialButton.hidden) {
            [UIView animateWithDuration:.25 animations:^{
                self.finishedTutorialButton.alpha = 0.0f;
                self.inviteFriendsButton.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.finishedTutorialButton.hidden = YES;
                self.inviteFriendsButton.hidden = YES;
            }];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isMemberOfClass:[ALInviteFriendsViewController class]]) {
        ALInviteFriendsViewController *ifvc = (ALInviteFriendsViewController *)segue.destinationViewController;
        ifvc.fromTutorial = YES;
    }
}


- (void)finishedTutorialButtonPressed:(id)sender
{
    [[ALUserManager manager] setUserCompletedTutorial:YES];
    [self performSegueWithIdentifier:kALSegueTutorialToMap sender:sender];
}

- (void)inviteFriendsButtonPressed:(id)sender
{
    [[ALUserManager manager] setUserCompletedTutorial:YES];
    [self performSegueWithIdentifier:kALSegueTutorialToInviteFriends sender:sender];
}

@end
