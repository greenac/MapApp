//
//  ALMapViewController.m
//  Around
//
//  Created by Andre Green on 8/21/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALNavViewController.h"
#import "ALMapViewController.h"
#import "Constants/ALConstants.h"
#import "ALMapAnnotation.h"
#import "ALLocationManager.h"
#import "ALMapManager.h"
#import "ALTicketView.h"
#import "ALEvent.h"
#import "ALScene.h"
#import "ALHours.h"
#import "ALAddress.h"
#import "ALMapTableViewCell.h"
#import "ALCommentor.h"
#import "ALMapCellView.h"
#import "ALFilterSlideView.h"
#import "UIImage+ImageEffects.h"
#import "ALEventListViewController.h"
#import "ALProfileCellView.h"
#import "ALProfileTableHeaderView.h"
#import "ALNotifications.h"
#import "ALMoreViewController.h"
#import "ALSegues.h"
#import "ALInviteFriendsViewController.h"
#import "ALComment.h"
#import "ALComment+Methods.h"
#import "ALAddCommentView.h"
#import "ALWebViewController.h"
#import "ALUserManager.h"
#import "ALMixPanelManager.h"
#import "ALCommentManager.h"
#import "ALUserDefaults.h"
#import "ALEventListViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ALProfilePicManager.h"


#define kALMapViewControllerTableGapTop             120.0f
#define kALMapViewControllerBackgroundViewTag       142
#define kALMapViewControllerProfileRowHeight        87.0f
#define kALCatchViewTag                             1042
#define kALTableBackgroundColor                     [[UIColor whiteColor] colorWithAlphaComponent:1.0f]
#define kALAnimationDurration                       .2f
#define kALProfileTableBackgroundColor              [UIColor colorWithRed:216.0f/255.0f green:216.0f/255.0f blue:216.0f/255.0f alpha:1.0f]
#define kALBanterGreen                              [UIColor colorWithRed:3.0f/255.0f green:177.0f/255.0f blue:146.0/255.0f alpha:1.0f]
#define kALMapViewControllerRateAppAlertTag         10876
#define kALMapViewControllerYelpCallTag             8540387
#define kALMapViewControllerNonSupportedRegionTag   483839


@interface ALMapViewController()

typedef NS_ENUM(NSUInteger, ALProfileCase) {
    ALProfileCaseDown = 0,
    ALProfileCaseUp,
    ALProfileCaseTicketUp,
    ALProfileCaseTicketMovingUp,
    ALProfileCaseFromTicketToProfile,
    ALProfileCaseFromProfileToTicket,
    ALProfileCaseTicketMovingDown,
    ALProfileCaseProfileMovingDown
};

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) ALLocationManager *locationManager;
@property (nonatomic, weak) ALTicketView *ticketView;
@property (nonatomic, weak) ALProfileTableHeaderView *profileHeaderView;
@property (nonatomic, strong) ALFilterSlideView *filterSlideView;
@property (nonatomic, strong) ALMapAnnotation *selectedAnnotation;
@property (nonatomic, strong) UIView *profileContainerView;
@property (nonatomic, assign) BOOL isFilterMode;
@property (nonatomic, assign) BOOL shouldCenterOnUser;
@property (nonatomic, assign) BOOL isNewAnnotationFromEventView;
@property (nonatomic, assign) BOOL deselectingAnnotation;
@property (nonatomic, assign) ALProfileCase profileCase;
@property (nonatomic, assign) NSUInteger tableViewId;
@property (nonatomic, strong) UIView *catchView;
@property (nonatomic, strong) NSDictionary *comments;
@property (nonatomic, strong) ALAddCommentView *addCommentView;
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIView *addCommentBlockingView;
@property (nonatomic, strong) NSDate *eventsLastUpdated;
@property (nonatomic, strong) ALMapManager *mapManager;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ALMapViewController

- (void)dealloc
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    self.mapManager = [ALMapManager manager];
    
    self.locationManager = [ALLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.persmissionState = ALLocationManagerPermissionStateDenied;
    
    // these methods only available on iOS8+
//    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [[UIApplication sharedApplication] sendAction:@selector(requestAlwaysAuthorization)
//                                                   to:self.locationManager
//                                                 from:self
//                                             forEvent:nil];
//    }

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization)
                                                   to:self.locationManager
                                                 from:self
                                             forEvent:nil];
    }
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    self.shouldCenterOnUser = YES;
    
    self.profileCase = ALProfileCaseDown;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = CGPointMake(self.view.center.x, .75*self.view.bounds.size.height);
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    [self registerForNotifications];
    
    // start timers
    [self startEventsTimer];
    [self startOccupancyTimer];
}

- (void)applicationMovedToForeground:(NSNotification *)notification
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self showRateAppPopUp];
}

- (void)applicationBecameActive:(NSNotification *)notification
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self showOppeningMessage];
}

- (UITableView *)tableView
{
    if (_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = kALMapViewControllerProfileRowHeight;
        _tableView.backgroundColor = kALProfileTableBackgroundColor;
    }
    
    return _tableView;
}

- (UIView*)catchView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_catchView) {
        _catchView = [[UIView alloc] initWithFrame:self.mapView.bounds];
    }
    return _catchView;
}

- (UIView *)profileContainerView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_profileContainerView) {
        _profileContainerView = [[UIView alloc] init];
    }
    return _profileContainerView;
}

- (ALAddCommentView *)addCommentView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_addCommentView) {
        _addCommentView = [ALAddCommentView initView];
        _addCommentView.delegate = self;
        _addCommentView.commentField.delegate = self;
        _addCommentView.commentField.returnKeyType = UIReturnKeySend;
        _addCommentView.commentButton.enabled = NO;
    }
    return _addCommentView;
}

- (UIView *)addCommentBlockingView
{
    if (!_addCommentBlockingView) {
        _addCommentBlockingView = [UIView new];
    }
    return _addCommentBlockingView;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormatter;
}

- (void)registerForNotifications
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBecameActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setMapAnnotations:)
                                                 name:kALNotificationMapManagerUpdatedAnnotations
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(isUserInSupportedRegion:)
                                                 name:kALNotificationMapManagerUserLocationSupported
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationMovedToForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)showOppeningMessage
{
    [ALMapManager.manager oppeningMessageWithCompletion:^(NSDictionary *responseDict) {
        NSString *message, *title;
        
        if (responseDict[@"message"]) {
            message = responseDict[@"message"];
            title = responseDict[@"title"];
        }
        
        if (message && ![message isEqualToString:@""]) {
            BOOL shouldShow = NO;
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSDate *currentDate = [NSDate date];
            NSString *dateString;
            if ([ud objectForKey:kALUserDefalutOppeningMessageDate]) {
                dateString = [ud objectForKey:kALUserDefalutOppeningMessageDate];
                NSDate *previouslyOpenedDate = [self.dateFormatter dateFromString:dateString];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                                               fromDate:previouslyOpenedDate
                                                                                 toDate:currentDate
                                                                                options:0];
                shouldShow = components.day >= 1;
            } else {
                shouldShow = YES;
            }
            
            if (shouldShow) {
                dateString = [self.dateFormatter stringFromDate:currentDate];
                
                [ud setObject:dateString forKey:kALUserDefalutOppeningMessageDate];
                [ud synchronize];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            }
        }
    }];
}

- (void)updateAnnotationsFromServer
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.mapManager getAnnotationsForUser];
    });
}

- (void)startEventsTimer
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSTimer *eventTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                           target:self
                                                         selector:@selector(updateEvents:)
                                                         userInfo:nil
                                                          repeats:YES];
    eventTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:19];
}

- (void)updateEvents:(NSTimer *)timer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.mapManager updateEvents];
    });
}

- (void)startOccupancyTimer
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSTimer *occupancyTimer = [NSTimer scheduledTimerWithTimeInterval:120
                                                               target:self
                                                             selector:@selector(updateOccupancy:)
                                                             userInfo:nil
                                                              repeats:YES];
    occupancyTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:137];
}

- (void)updateOccupancy:(NSTimer *)timer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self.mapManager updateOccupancy];
    });
}

- (void)isUserInSupportedRegion:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if (info[kALNotificationMapManagerUserLocationSupported]) {
        NSNumber *isSupported = info[kALNotificationMapManagerUserLocationSupported];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSupported.boolValue) {
                [self.spinner stopAnimating];
            } else {
                [self showNotSupportedRegionAlert];
            }
        });
    }
}

- (void)setMapAnnotations:(NSNotification *)notification
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *toAdd = [ALMapManager.manager annotationsToAdd];
        NSArray *toRemove = [ALMapManager.manager annotationsToRemove];
        
        NSNumber *performerCounter = @(0);
        NSNumber *happyCounter = @(0);
        NSNumber *foodtruckCounter = @(0);
        
        for (ALMapAnnotation *annotation in toAdd) {
            if ([annotation.event.type isEqualToString:@"happyHour"]) {
                happyCounter = @(happyCounter.intValue + 1);
            } else if ([annotation.event.type isEqualToString:@"performer"]) {
                performerCounter = @(performerCounter.intValue + 1);
            } else {
                foodtruckCounter = @(foodtruckCounter.intValue + 1);
            }
        }
        
        
        if (toRemove.count > 0) {
            [self.mapView removeAnnotations:toRemove];
        }
        
        if (toAdd.count > 0) {
            [self.mapView addAnnotations:toAdd];
        }
    });
}

- (void)checkIfUserIsInSupportedRegion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.mapManager checkIfUsersCityIsSupported:self.mapView.userLocation.coordinate];
    });
}

- (void)showNotSupportedRegionAlert
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner stopAnimating];
        
        NSString *message = NSLocalizedString(@"Oh no! You're not in San Francisco! What can you do about this?  Move to San Francisco! If that's not an option, send an e-mail to our growth team and let us know where to expand to next!\nBanter on!", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UNSUPPORTED REGION", nil)
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Send Email", nil];
        alert.tag = kALMapViewControllerNonSupportedRegionTag;
        [alert show];
    });
}

- (void)showRateAppPopUp
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *timesOpened = [ud objectForKey:kALUserDefalutRateAppPopUpCounter];
    static NSInteger fireTarget = 6;
    
    if (timesOpened.integerValue == fireTarget) {
        NSString *message = NSLocalizedString(@"Hi there! If you're a Banter fan, please rate the app and help spread the word!\nLet's Banter!", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rate Banter!", nil)
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                              otherButtonTitles:NSLocalizedString(@"Rate Now", nil), NSLocalizedString(@"Rate Later", nil), nil];
        alert.tag = kALMapViewControllerRateAppAlertTag;
        [alert show];
    }
}

- (void)setCatchViewTapRecognizerSelector:(SEL)tapSelector
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    for (UIGestureRecognizer *gr in self.catchView.gestureRecognizers) {
        [self.catchView removeGestureRecognizer:gr];
    }
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:tapSelector];
    tgr.numberOfTapsRequired = 1;
    
    [self.catchView addGestureRecognizer:tgr];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([segue.identifier isEqualToString:kALSegueMapToMore]) {
        ALMoreViewController *moreViewController = segue.destinationViewController;
        moreViewController.backgorundImage = [self blurredImageOfView:self.view];
    } else if ([segue.identifier isEqualToString:kALSegueMapToInviteFriends]) {
        ALInviteFriendsViewController *inviteController = segue.destinationViewController;
        inviteController.event = self.selectedAnnotation.event;
    }
}

- (UIImage*)blurredImageOfView:(UIView *)view
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:NO];
    
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredImage = [snapshotImage applyLightEffect];
    
    UIGraphicsEndImageContext();
    
    return blurredImage;
}

#pragma mark - IBActions
- (IBAction)locationButtonPushed:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.shouldCenterOnUser = YES;
    [self mapView:self.mapView didUpdateUserLocation:self.mapView.userLocation];
}

- (void)eventListButtonPushed:(id)sender
{
    [super eventListButtonPushed:sender];
    
    UIViewController *viewController = [self.navigationController.viewControllers lastObject];
    if ([viewController isMemberOfClass:[ALEventListViewController class]]) {
        ALEventListViewController *evc = (ALEventListViewController *)viewController;
        evc.delegate = self;
    }
}

#pragma mark - move tableview methods

- (void)createProfileView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    //create ticket view
    UIImage *icon = [ALProfilePicManager.manager iconForEvent:self.selectedAnnotation.event
                                                     iconType:ALEventIconTypeMapPin];
    
    self.ticketView = [ALTicketView initView];
    self.ticketView.frame = CGRectMake(0.0f,
                                       0.0f,
                                       self.ticketView.bounds.size.width,
                                       self.ticketView.bounds.size.height);
    self.ticketView.delegate = self;
    self.ticketView.backgroundColor = kALTableBackgroundColor;
    [self.ticketView setUpWithAnnotation:self.selectedAnnotation image:icon];
    self.ticketView.userInteractionEnabled = YES;
    
    // create profile header view
    NSString *address2Text = [NSString stringWithFormat:@"%@, %@ %@",
                              self.selectedAnnotation.event.address.city,
                              self.selectedAnnotation.event.address.state,
                              self.selectedAnnotation.event.address.zip];
    NSString *yelpImageName = [self.selectedAnnotation.event.scene imageNameForYelpImageUrl];
    NSString *openHours = [self.selectedAnnotation.event.scene.hours hoursForCurrentDay];
    NSString *openToday = NSLocalizedString(@"Open Today", nil);
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString *openHoursSansWhitespaces = [openHours stringByTrimmingCharactersInSet:charSet];
    
    if ([openHoursSansWhitespaces isEqualToString:@""] || !openHours) {
        openToday = NSLocalizedString(@"Swing By!", nil);
    }
    
    self.profileHeaderView = [ALProfileTableHeaderView initView];
    self.profileHeaderView.frame = CGRectMake(0.0f,
                                              self.ticketView.bounds.size.height,
                                              self.profileHeaderView.bounds.size.width,
                                              self.profileHeaderView.bounds.size.height);
    self.profileHeaderView.delegate = self;
    self.profileHeaderView.address1Label.text = self.selectedAnnotation.event.address.address;
    self.profileHeaderView.address2Label.text = address2Text;
    self.profileHeaderView.phoneNumberLabel.text = self.selectedAnnotation.event.scene.phoneNumber;
    self.profileHeaderView.yelpRatingImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", yelpImageName]];
    self.profileHeaderView.openTodayLabel.text = openToday;
    self.profileHeaderView.openTodayHoursLabel.text = openHours;
    
//    //self.profileHeaderView.backgroundColor = kALTableBackgroundColor;
//    self.profileHeaderView.backgroundColor = [UIColor greenColor];
//    CGFloat tableHeight = [self tableHeight];
//    self.tableView.frame = CGRectMake(0.0,
//                                      self.profileHeaderView.frame.origin.y + self.profileHeaderView.frame.size.height,
//                                      self.view.bounds.size.width,
//                                      tableHeight);
//    [self.tableView reloadData];
//    
//    // draw add comment bar
//    
//    self.addCommentView.frame = CGRectMake(0.0f,
//                                           CGRectGetMaxY(self.profileHeaderView.frame) + tableHeight,
//                                           self.addCommentView.bounds.size.width,
//                                           self.addCommentView.bounds.size.height);
//    
//    //self.addCommentView.backgroundColor = self.ticketView.backgroundColor;
//    self.addCommentView.backgroundColor = [UIColor blueColor];
//    [self.addCommentView.commentButton setTitleColor:kALBanterGreen forState:UIControlStateNormal];
//    self.addCommentView.commentField.text = @"";
//    self.addCommentView.commentField.placeholder = NSLocalizedString(@"Add A Comment", nil);
    
    // add table view container
    CGFloat height = self.ticketView.bounds.size.height + self.profileHeaderView.bounds.size.height;
    
    self.profileContainerView.frame = CGRectMake(0.0f,
                                                 self.view.bounds.size.height,
                                                 self.view.bounds.size.width,
                                                 height);
    [self.view addSubview:self.profileContainerView];
    
    // add subview to container view
    [self.profileContainerView addSubview:self.ticketView];
    [self.profileContainerView addSubview:self.profileHeaderView];
//    [self.profileContainerView addSubview:self.tableView];
//    [self.profileContainerView addSubview:self.addCommentView];
    
    [self setCatchViewTapRecognizerSelector:@selector(moveProfileViewDownToShowTicket)];
    [self.view insertSubview:self.catchView belowSubview:self.mapView];
}

- (void)moveProfileViewUpToShowTicketView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.profileCase = ALProfileCaseTicketMovingUp;

    [self createProfileView];
    
    [UIView animateWithDuration:kALAnimationDurration animations:^{
        self.profileContainerView.frame = CGRectMake(0.0f,
                                                     self.view.bounds.size.height - self.ticketView.bounds.size.height,
                                                     self.profileContainerView.bounds.size.width,
                                                     self.profileContainerView.bounds.size.height);
        self.profileCase = ALProfileCaseTicketUp;
    }];
}

- (void)moveProfileViewUp
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.profileCase = ALProfileCaseFromTicketToProfile;
    
    [self lockMap];
    
    [self setCatchViewTapRecognizerSelector:@selector(moveProfileViewUpToShowTicketView)];
    [self.view insertSubview:self.catchView belowSubview:self.mapView];
    
    [UIView animateWithDuration:kALAnimationDurration animations:^{
        self.profileContainerView.frame = CGRectMake(0.0f,
                                                     self.view.bounds.size.height - self.profileContainerView.bounds.size.height,
                                                     self.profileContainerView.bounds.size.width,
                                                     self.profileContainerView.bounds.size.height);
//    self.tableView.frame = CGRectMake(0.0f,
//                                      CGRectGetMaxY(self.profileHeaderView.frame),
//                                      self.profileContainerView.bounds.size.width,
//                                      [self tableHeight]);
//
//    self.tableViewContainerView.frame = CGRectMake(0.0f,
//                                                   self.view.bounds.size.height - height,
//                                                   self.tableViewContainerView.bounds.size.width,
//                                                   height);
    } completion:^(BOOL finished) {
        [self moveMapCenterToAnnotation:self.selectedAnnotation];
        //[self.tableView flashScrollIndicators];
        [self.view bringSubviewToFront:self.profileContainerView];
        self.profileCase = ALProfileCaseUp;
    }];
}

- (void)moveProfileViewDownToShowTicket
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.profileCase = ALProfileCaseFromProfileToTicket;
    self.selectedAnnotation.selected = NO;
    
    [self.catchView removeFromSuperview];
    
    [UIView animateWithDuration:kALAnimationDurration animations:^{
        self.profileContainerView.frame = CGRectMake(0.0f,
                                                     self.view.bounds.size.height - self.ticketView.bounds.size.height,
                                                     self.profileContainerView.bounds.size.width,
                                                     self.profileContainerView.bounds.size.height);
    } completion:^(BOOL finished) {
        self.profileCase = ALProfileCaseTicketUp;
        [self unlockMap];
    }];
}

- (void)moveProfileViewOffScreenWithCompletion:(void(^)(void))completionBlock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.profileCase = ALProfileCaseProfileMovingDown;
    
    self.selectedAnnotation.selected = NO;
    
    [self.catchView removeFromSuperview];

    [UIView animateWithDuration:kALAnimationDurration animations:^{
        self.profileContainerView.frame = CGRectMake(0.0f,
                                                       self.view.bounds.size.height,
                                                       self.profileContainerView.bounds.size.width,
                                                       self.profileContainerView.bounds.size.height);
    } completion:^(BOOL finished) {
        [self unlockMap];
        self.profileCase = ALProfileCaseDown;
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)commentAddedToProfileView
{
    
}

- (CGFloat)tableHeight
{
    static NSUInteger maxRows = 3;
    NSArray *commentsForScene = [self commentsForEvent:self.selectedAnnotation.event];
    NSUInteger rows = (commentsForScene.count < maxRows) ? commentsForScene.count : maxRows;
    CGFloat tableMaxHeight = maxRows*kALMapViewControllerProfileRowHeight;
    CGFloat height = rows*kALMapViewControllerProfileRowHeight;
    if (height > tableMaxHeight) {
        height = tableMaxHeight;
    }
    
    return height;
}

- (void)moveAddCommentViewUp:(NSValue *)frameValue withDurration:(NSNumber *)durration andCruve:(NSNumber *)curve
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.addCommentView.commentButton setTitle:@"cancel" forState:UIControlStateNormal];
    self.addCommentView.commentButton.enabled = YES;
    
    CGRect newFrame = CGRectMake(0.0f,
                                 frameValue.CGRectValue.origin.y - self.addCommentView.bounds.size.height,
                                 self.addCommentView.bounds.size.width,
                                 self.addCommentView.bounds.size.height);
    
    self.addCommentBlockingView.frame = CGRectMake(0.0f,
                                                   0.0f,
                                                   self.view.bounds.size.width,
                                                   newFrame.origin.y);
    [self.view addSubview:self.addCommentBlockingView];
    [self.view bringSubviewToFront:self.addCommentBlockingView];
    
    [UIView animateWithDuration:durration.floatValue delay:0 options:curve.integerValue animations:^{
        self.addCommentView.frame = [self.view convertRect:newFrame toView:self.profileContainerView];
    } completion:^(BOOL finished) {
        [self.view addSubview:self.addCommentView];
        self.addCommentView.frame = newFrame;
    }];
}

- (void)moveAddCommentViewDown:(NSValue *)frameValue withDurration:(NSNumber *)durration andCruve:(NSNumber *)curve
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.addCommentView.commentButton setTitle:@"comment" forState:UIControlStateNormal];
    self.addCommentView.commentButton.enabled = NO;
    
    CGRect moveToFrame = frameValue.CGRectValue;
    CGRect newFrame = CGRectMake(0.0f,
                                 moveToFrame.origin.y - self.addCommentView.bounds.size.height,
                                 self.addCommentView.bounds.size.width,
                                 self.addCommentView.bounds.size.height);
    
    [self.addCommentBlockingView removeFromSuperview];
    
    [UIView animateWithDuration:durration.floatValue delay:0 options:curve.integerValue animations:^{
        self.addCommentView.frame = newFrame;
    } completion:^(BOOL finished) {
        [self.profileContainerView addSubview:self.addCommentView];
        self.addCommentView.frame = [self.view convertRect:newFrame toView:self.profileContainerView];
    }];
}

- (void)annotationPressed
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [[ALMixPanelManager manager] eventTapped:self.selectedAnnotation.event];
    
    [self moveProfileViewUpToShowTicketView];
    
    // self.comments = [ALCommentManager.manager getCommentsFromDbWithSceneIds:@[annotation.event.scene.sceneId]];
    // [self alterProfileTableSize];
    
//    [ALCommentManager.manager getCommentsForEvents:@[annotation.event] withCallBack:^(NSDictionary *comments) {
//        self.comments = comments;
//        [self alterProfileTableSize];
//    }];
}

- (NSArray *)commentsForEvent:(ALEvent *)event
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSArray *comments = [NSArray new];
    
    if (self.comments[event.scene.sceneId]) {
        comments = self.comments[event.scene.sceneId];
    }
    
    return comments;
}

- (void)keyBoardWillShow:(NSNotification *)notification
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSDictionary *info = notification.userInfo;
    NSValue *keyboardEndFrameValue = info[UIKeyboardFrameEndUserInfoKey];
    NSNumber *animationTime = info[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = info[UIKeyboardAnimationCurveUserInfoKey];
    
    self.keyboardFrame = keyboardEndFrameValue.CGRectValue;

    [self moveAddCommentViewUp:keyboardEndFrameValue
                 withDurration:animationTime
                      andCruve:animationCurve];
}

- (void)keyBoardWillHide:(NSNotification *)notification
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSDictionary *info = notification.userInfo;
    NSValue *keyboardEndFrameValue = info[UIKeyboardFrameEndUserInfoKey];
    NSNumber *animationTime = info[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = info[UIKeyboardAnimationCurveUserInfoKey];
    
    self.keyboardFrame = keyboardEndFrameValue.CGRectValue;
    
    [self moveAddCommentViewDown:keyboardEndFrameValue
                   withDurration:animationTime
                        andCruve:animationCurve];
}

#pragma mark - ALTicketViewDelegate methods
- (void)ticketViewTapped:(ALTicketView *)ticketView
{
    NSLog(@"%@::%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (self.profileCase == ALProfileCaseUp) {
        [self moveProfileViewDownToShowTicket];
    } else if (self.profileCase == ALProfileCaseTicketUp) {
        [self moveProfileViewUp];
    }
}

- (void)inviteButtonPushedOnTicketView:(ALTicketView *)headerView
{
    NSLog(@"%@::%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [[ALMixPanelManager manager] eventShared:self.selectedAnnotation.event from:@"Ticket"];
    [self performSegueWithIdentifier:kALSegueMapToInviteFriends sender:nil];
}

#pragma mark - ALMapTableHeaderViewDelegate methods
- (void)commentButtonPushedTicketView:(ALTicketView *)headerView
{
    NSLog(@"%@::%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSLog(@"comment button pushed");
}

#pragma mark - Map View Delegate Methods

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSLog(@"%@::%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([annotation isKindOfClass:[ALMapAnnotation class]]) {
        ALMapAnnotation *alAnnotation = (ALMapAnnotation*)annotation;
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kALAnnotationReuseIdenifier];
        
        if (annotationView) {
            annotationView.annotation = annotation;
        }
        
        annotationView = [alAnnotation annotationView];
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self.mapManager updateUserLocation:userLocation.location.coordinate];
    
    if (self.shouldCenterOnUser) {
        MKCoordinateRegion region;
        CLLocationCoordinate2D userPosition = userLocation.coordinate;
        region.center = userPosition;
        region.span = MKCoordinateSpanMake(.01, .01);
        region = [mapView regionThatFits:region];
        
        [mapView setRegion:region animated:YES];
        
        self.shouldCenterOnUser = NO;
        [self updateAnnotationsFromServer];
        [self checkIfUserIsInSupportedRegion];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if ([view.annotation isKindOfClass:[ALMapAnnotation class]]) {
        ALMapAnnotation *deselectedAnnotation = (ALMapAnnotation *)view.annotation;
        deselectedAnnotation.selected = NO;
        view.image = deselectedAnnotation.annotationImage;
        self.deselectingAnnotation = YES;
        if (self.profileCase == ALProfileCaseTicketUp) {
            // case where annotation is being deselected and another is being selected
            self.profileCase = ALProfileCaseTicketMovingDown;
            [self moveProfileViewOffScreenWithCompletion:^{
                self.deselectingAnnotation = NO;
                if (self.selectedAnnotation == deselectedAnnotation) {
                    self.selectedAnnotation = nil;
                } else {
                    [self moveProfileViewUpToShowTicketView];
                }
            }];
        } else if (self.profileCase == ALProfileCaseUp) {
            self.profileCase = ALProfileCaseProfileMovingDown;
            [self moveProfileViewOffScreenWithCompletion:^{
                self.deselectingAnnotation = NO;
                [self moveProfileViewUpToShowTicketView];
            }];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // no other pin is selected
    if ([view.annotation isKindOfClass:[ALMapAnnotation class]]) {
        self.selectedAnnotation = (ALMapAnnotation *)view.annotation;
        self.selectedAnnotation.selected = YES;
        view.image = [self.selectedAnnotation annotationImage];
        if (self.profileCase == ALProfileCaseDown) {
            // case where no annotation is selected. move ticket view up
            self.selectedAnnotation.selected = YES;
            view.image = [self.selectedAnnotation annotationImage];
            [self annotationPressed];
        } else if ((self.profileCase == ALProfileCaseTicketMovingDown ||
                    self.profileCase == ALProfileCaseTicketUp) &&
                   !self.deselectingAnnotation) {
            // case where 2nd annoation is pressed. move ticket down and back up with new annotation
            
            [self moveProfileViewOffScreenWithCompletion:^{
                [self annotationPressed];
            }];
        }
        
//        self.comments = [ALCommentManager.manager getCommentsFromDbWithSceneIds:@[self.selectedAnnotation.event.scene.sceneId]];
//        
//        NSMutableArray *testComments = [NSMutableArray new];
//        for (NSNumber *num in self.comments) {
//            NSArray *commentsArray = self.comments[num];
//            for (ALComment *testcomment in commentsArray) {
//                [testComments addObject:testcomment.asDictionary];
//            }
//        }
//        
//        NSLog(@"test comments: %@", testComments.description);
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            [[ALCommentManager manager] getCommentsForEvents:@[self.selectedAnnotation.event] withCallBack:^(NSDictionary *comments) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.comments = comments;
//                    //[self alterProfileTableSize];
//                });
//            }];
//        });
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.mapManager.visibleRect = self.mapView.visibleMapRect;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
}

#pragma mark - custom map methods
- (void)lockMap
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.mapView.userInteractionEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
}

- (void)unlockMap
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.mapView.userInteractionEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
}

- (void)moveMapCenterToAnnotation:(ALMapAnnotation *)annotation
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self.mapView setCenterCoordinate:annotation.coordinate];
    
    CGPoint displayPoint = CGPointMake(self.view.center.x, self.view.bounds.size.height - .5*kALMapViewControllerTableGapTop);
    CLLocationCoordinate2D displayCoord = [self.mapView convertPoint:displayPoint toCoordinateFromView:self.mapView];
    [self.mapView setCenterCoordinate:displayCoord animated:YES];
}

#pragma mark - location manager delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized ||
        status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [manager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusDenied) {
        NSString *message = NSLocalizedString(@"You don't like apps that stalk you and drain your battery, and neither do we! "
                                              "We've made a few tricks so Banter will only track your location when you're actually "
                                              "looking at the app. On your home screen, go to Settings-Banter-Location and select "
                                              "While Using the App. Unfortunately, we currently can't do this through the app, "
                                              "but hopefully we'll be able to soon.\nLet's Banter!", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WE'RE ON YOUR SIDE!", nil)
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (self.comments[self.selectedAnnotation.event.scene.sceneId]){
        NSArray *comments = self.comments[self.selectedAnnotation.event.scene.sceneId];
        return comments.count;
    }
    
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    //profile table view cell setup
    static NSString *cellId = @"ALProfileCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray *commentsForScene = [self commentsForEvent:self.selectedAnnotation.event];
    ALComment *comment = commentsForScene[indexPath.row];
    
    ALProfileCellView *profileCellView = [ALProfileCellView initView];
    [profileCellView setInfoWithComment:comment];
    [cell.contentView addSubview:profileCellView];
    
    return cell;
}

- (void)makePhoneCall
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        NSString *phoneNumber = self.selectedAnnotation.event.scene.phoneNumber;
        NSString *cleanedNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
        NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", cleanedNumber]];
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
}

#pragma mark ALProfileTableHeaderViewDelegate Methods
- (void)profileTableHeaderViewPhoneNumberLabelTouched:(ALProfileTableHeaderView *)profileHeaderView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSString *message = [NSString stringWithFormat:@"Call %@ at %@?",
                         self.selectedAnnotation.event.scene.name,
                         self.selectedAnnotation.event.scene.phoneNumber];
    NSString *title = [NSString stringWithFormat:@"%@", self.selectedAnnotation.event.scene.name];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Call", nil];
    alert.tag = kALMapViewControllerYelpCallTag;
    [alert show];
}

- (void)profileTableHeaderYelpLogoTouched:(ALProfileTableHeaderView *)profileHeaderView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSString *urlString = self.selectedAnnotation.event.scene.yelpUrl;
    if (urlString) {
        ALWebViewController *wvc = [[ALWebViewController alloc] initWithUrlString:urlString];
        wvc.exitBlock = ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:wvc];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)profileTableHeaderViewAddressLabelTouched:(ALProfileTableHeaderView *)profileHeaderView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark view controller helper methods
- (BOOL)view:(UIView *)parentView containsView:(UIView *)childView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    BOOL hasView = NO;
    for (UIView *view in parentView.subviews) {
        if (view == childView) {
            hasView = YES;
            break;
        }
    }
    return hasView;
}

- (UIView *)view:(UIView *)parentView containsViewWithTag:(NSUInteger)tag
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    UIView *targetView;
    for (UIView *view in parentView.subviews) {
        if (view.tag == tag) {
            targetView = view;
            break;
        }
    }
    return targetView;
}

#pragma mark - alert view delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (alertView.tag == kALMapViewControllerYelpCallTag) {
        if (buttonIndex == 1) {
            [self makePhoneCall];
        }
    } else if (alertView.tag == kALMapViewControllerRateAppAlertTag) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSNumber *timesOpened = [ud objectForKey:kALUserDefalutRateAppPopUpCounter];
        if (buttonIndex == 1) {
            //rate now
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id929223395"]];
            timesOpened = @(timesOpened.integerValue + 1);
        } else if (buttonIndex == 2) {
            //rate later
            timesOpened = @(0);
        }
        
        [ud setObject:timesOpened forKey:kALUserDefalutRateAppPopUpCounter];
        [ud synchronize];
    } else if (alertView.tag == kALMapViewControllerNonSupportedRegionTag) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:grow@thebanterapp.com"]];
        }
    }
    
    if (buttonIndex == 0 && self.spinner.isAnimating) {
        [self.spinner stopAnimating];
    }
}

#pragma mark - text field delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.addCommentView.commentField) {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
        NSString *cleanedText = [newText stringByTrimmingCharactersInSet:set];
        self.addCommentView.commentButton.enabled = ![cleanedText isEqualToString:@""];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.addCommentView.commentField) {
        [textField resignFirstResponder];
        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" \n"];
        NSString *strippedText = [textField.text stringByTrimmingCharactersInSet:charSet];
        
        if (![strippedText isEqual:@""]) {
            // save to server
            [[ALCommentManager manager] addCommentForScene:self.selectedAnnotation.event.scene
                                                   comment:strippedText
                                              withCallBack:nil];
            //update UI
            [ALCommentManager.manager saveCommentForCurrentUserToDb:strippedText
                                                           forScene:self.selectedAnnotation.event.scene];
            self.comments = [ALCommentManager.manager getCommentsFromDbWithSceneIds:@[self.selectedAnnotation.event.scene.sceneId]];
            
            // TODO -- make chanages to ui when comments are updated
            // need to readd way to alter the tablesize after a comment is added
            
        }
        
        textField.text = @"";
    }
    
    return YES;
}

#pragma mark - add comment view delegate methods
- (void)addCommentView:(ALAddCommentView *)commentView commentButtonPushed:(UIButton *)button
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.addCommentView.commentField.text = @"";
    [self.addCommentView.commentField resignFirstResponder];
}

#pragma mark - event list view controller delegate methods
- (void)eventListViewController:(ALEventListViewController *)viewController hadAnnotationSelected:(ALMapAnnotation *)annotation
{
    self.isNewAnnotationFromEventView = YES;
    ALMapAnnotation *toDeselect = self.selectedAnnotation;
    self.selectedAnnotation = annotation;
    [self mapView:self.mapView didDeselectAnnotationView:toDeselect.annotationView];
    [self.mapView selectAnnotation:self.selectedAnnotation animated:YES];
}

@end
