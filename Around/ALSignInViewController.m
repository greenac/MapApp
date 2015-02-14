//
//  ALSignInViewController.m
//  Banter!
//
//  Created by Andre Green on 10/2/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALSignInViewController.h"
#import "ALAppDelegate.h"
#import "ALFaceBookManager.h"
#import "ALNotifications.h"
#import "ALSegues.h"
#import "ALUserDefaults.h"
#import "ALSignInEmailViewController.h"
#import "ALUserManager.h"
#import <QuartzCore/QuartzCore.h>

@interface ALSignInViewController ()

@property (nonatomic, strong) UIImageView *splashView;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, assign) BOOL flowChosen;

@end

@implementation ALSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *signInImageName;
    if ([UIScreen mainScreen].bounds.size.height <= 481.0f) {
        signInImageName = @"splash_screen4";
    } else {
        signInImageName = @"splash_screen5";
    }
    
    UIImage *splashImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", signInImageName]];
    self.splashView = [[UIImageView alloc] initWithImage:splashImage];
    [self.view addSubview:self.splashView];
    [self.view bringSubviewToFront:self.splashView];
    
    self.facebookSignInButton.clipsToBounds = YES;
    self.facebookSignInButton.layer.cornerRadius = 2.0f;
    
    self.emailSignInButton.clipsToBounds = YES;
    self.emailSignInButton.layer.cornerRadius = 2.0f;
    
    self.faceBookUserHasEmail = YES;
    self.flowChosen = NO;
    
    [self registerForNotifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super viewDidAppear:animated];
    [self chooseInitialFlow];
}

- (void)dealloc
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForNotifications
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginWithFacebookSuccesful)
                                                 name:kALNotificationUserLoggedInThroughFacebookSuccessful
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginWithFacebookFailed)
                                                 name:kALNotificationUserLogginThroughFacebookFailed
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(faceBookUserDoesNotHaveEmailAddress)
                                                 name:kALNotificationFacebookUserHasNoEmail
                                               object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.flowChosen = YES;
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if ([segue.identifier isEqualToString:kALSegueLoginWithEmail]) {
        ALSignInEmailViewController *svc = (ALSignInEmailViewController *)segue.destinationViewController;
        svc.loginMode = (sender == self.loginButton);
        svc.showMessageForNoFacebookEmail = !self.faceBookUserHasEmail;
    }
}

- (IBAction)faceBookButtonPushed:(id)sender
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [[ALFaceBookManager manager] signIn];
}

- (IBAction)emailButtonPushed:(id)sender
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    dispatch_async (dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:kALSegueLoginWithEmail sender:sender];
    });
}

- (IBAction)logginButtonPushed:(id)sender
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    dispatch_async (dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:kALSegueLoginWithEmail sender:sender];
    });
}

- (void)loginWithFacebookSuccesful
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (!self.flowChosen) {
        dispatch_async (dispatch_get_main_queue(), ^{
            if ([[ALUserManager manager] hasUserCompletedTutorial]) {
                // if user has completed tutorial go to map
                [self performSegueWithIdentifier:kALSegueSignInToMap sender:nil];
            } else {
                // continue to tutorial
                [self performSegueWithIdentifier:kALSegueSignInToTutorial sender:nil];
            }
        });        
    }
}

- (void)faceBookUserDoesNotHaveEmailAddress
{
    // user does not have an email address associated with their facebook account
    // (or didn't share with Banter!. to handle this case we channel the user to the
    // email sign in page and present them with information on why we can't sign them
    // in without an address. Present info about how to rectify on facebook or use email
    // sign in process
    dispatch_async(dispatch_get_main_queue(), ^{
        self.faceBookUserHasEmail = NO;
        [self performSegueWithIdentifier:kALSegueLoginWithEmail sender:nil];
    });
}

- (BOOL)isUserSignedIn
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return [[ALUserManager manager] isUserSignedIn];
}

- (BOOL)hasUserCompletedTutorial
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return [[ALUserManager manager] hasUserCompletedTutorial];
}

- (void)chooseInitialFlow
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    dispatch_async (dispatch_get_main_queue(), ^{
        if ([self isUserSignedIn]) {
            // user has signed in previously. Check if user needs to see tutorial.
            if ([self hasUserCompletedTutorial]) {
                [self performSegueWithIdentifier:kALSegueSignInToMap sender:nil];
            } else {
                [self performSegueWithIdentifier:kALSegueSignInToTutorial sender:nil];
            }
        } else {
            // user needs to see login screen, so remove splash view
            [UIView animateWithDuration:.2f animations:^{
                self.splashView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self.splashView removeFromSuperview];
            }];
        }
    });
}

- (void)loginWithFacebookFailed
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed", nil)
                                                message:NSLocalizedString(@"Sorry, Banter! could not log you in with Facebook at this time. Please try again later or log in with email.", nil)
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [self.alertView show];
}
@end
