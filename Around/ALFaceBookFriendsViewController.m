//
//  ALFaceBookFriendsViewController.m
//  Banter!
//
//  Created by Andre Green on 1/14/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "ALFaceBookFriendsViewController.h"
#import "ALFriendCircleView.h"
#import "ALUserManager.h"
#import "ALUser.h"
#import "ALFriend.h"
#import "ALProfilePicManager.h"

#define kALBanterGreen [UIColor colorWithRed:3.0f/255.0f green:177.0f/255.0f blue:146.0/255.0f alpha:1.0f]



@interface ALFaceBookFriendsViewController ()

@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) UILabel *topBarLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *bottomBarView;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation ALFaceBookFriendsViewController

- (void)viewDidLoad {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.topBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 80.0f)];
    self.topBarView.backgroundColor = kALBanterGreen;
    [self.view addSubview:self.topBarView];
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.topBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                 statusBarHeight,
                                                                 self.topBarView.bounds.size.width,
                                                                 self.topBarView.bounds.size.height - statusBarHeight)];
    self.topBarLabel.text = NSLocalizedString(@"Facebook Friends On Banter!", nil);
    self.topBarLabel.font = [UIFont systemFontOfSize:21.0f];
    self.topBarLabel.textColor = [UIColor whiteColor];
    self.topBarLabel.textAlignment = NSTextAlignmentCenter;
    [self.topBarView addSubview:self.topBarLabel];
    
    CGFloat bottomBarViewHeight = self.fromTutorial ? 75.0f : 50.0f;
    
    self.bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                  self.view.bounds.size.height - bottomBarViewHeight,
                                                                  self.view.bounds.size.width,
                                                                  bottomBarViewHeight)];
    self.bottomBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomBarView];
    
    if (!self.fromTutorial) {
        UIView *bottomViewLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bottomBarView.bounds.size.width, 1.0f)];
        bottomViewLine.backgroundColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
        [self.bottomBarView addSubview:bottomViewLine];
        
        self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                     bottomViewLine.bounds.size.height,
                                                                     80.0f,
                                                                     self.bottomBarView.bounds.size.height - bottomViewLine.bounds.size.height)];
        [self.backButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
        [self.backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self.backButton setTitleColor:kALBanterGreen forState:UIControlStateNormal];
        [self.bottomBarView addSubview:self.backButton];
    }
    
    CGFloat scrollHeight = self.view.bounds.size.height - self.topBarLabel.bounds.size.height - self.bottomBarView.bounds.size.height;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.topBarView.bounds.size.height,
                                                                     self.view.bounds.size.height,
                                                                     scrollHeight)];
    [self.scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 20.0f, 0.0f)];
    [self.view addSubview:self.scrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self addFacebookFriends];
    
    [self.view bringSubviewToFront:self.bottomBarView];
}

- (void)addFacebookFriends
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ALUser *currentUser = [[ALUserManager manager] currentUser];
    
    if (currentUser.friends.allObjects.count > 1) {
        static CGFloat ySpacer = 25.0f;
        static CGFloat xPadding = 10.0f;
        static CGFloat yPadding = 10.0f;
        static NSUInteger maxColumns = 3;
        
        NSMutableArray *friendViews = [NSMutableArray new];
        CGRect circleFrame = CGRectMake(0.0, 0.0, 75.0f, 100.0f);
        NSArray *friends = currentUser.friends.allObjects;
        for (ALFriend *friend in friends) {
            if (friend.email) {
                NSString *name = [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
                ALFriendCircleView *circleView = [[ALFriendCircleView alloc] initWithFrame:circleFrame
                                                                                       pic:[UIImage imageNamed:@"userimage"]
                                                                                      name:name];
                [circleView getPictureForUsername:friend.email];
                [friendViews addObject:circleView];
            }
        }
        
        CGFloat y0 = yPadding;
        CGFloat x0 = xPadding;
        CGFloat xSpacer = (self.view.bounds.size.width - maxColumns*circleFrame.size.width - 2.0f*xPadding)/(maxColumns - 1);
        
        for (NSUInteger i=0; i < friendViews.count; i++) {
            ALFriendCircleView *circleView = friendViews[i];
            circleView.frame = CGRectMake(x0, y0, circleView.frame.size.width, circleView.frame.size.height);
        
            if ((i+1) % maxColumns == 0) {
                if (i != 0) {
                    y0 += ySpacer + circleView.frame.size.height;
                    x0 = xPadding;
                }
            } else {
                x0 += xSpacer + circleView.frame.size.width;
            }
            
            [self.scrollView addSubview:circleView];
        }
        
        [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, y0)];
    }
}

- (void)backButtonPressed
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end