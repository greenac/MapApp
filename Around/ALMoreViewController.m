//
//  ALMoreViewController.m
//  Banter!
//
//  Created by Andre Green on 9/25/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALMoreViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ALUserManager.h"
#import "ALSegues.h"
#import "ALWebViewController.h"
#import "ALFaceBookFriendsViewController.h"
#import "ALFaceBookManager.h"
#import "ALUser.h"

#define kALMorePageColor            [UIColor colorWithRed:3.0f/255.0f green:177.0f/255.0f blue:146.0/255.0f alpha:1.0f]
#define kALMoreFaceBookUrl          @"https://www.facebook.com/TheBanterApp"
#define kALMoreFaceBookAppUrl       @"fb://profile/1475332082718230"
#define kALMoreInstagramUrl         @"http://instagram.com/TheBanterApp"
#define kALMoreWebsiteUrl           @"http://thebanterapp.com"
#define kALMoreBanterSupportEmail   @"mailto:contact@thebanterapp.com"

@interface ALMoreViewController ()


@end

@implementation ALMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filterBarButton.enabled = NO;
    
    static CGFloat buttonBorderWidth = 1.0f;
    static CGFloat cornerBorderRadius = 3.0f;
    UIColor *buttonColor = kALMorePageColor;
    
    [self.faceBookFriendsButton setTitleColor:buttonColor forState:UIControlStateNormal];
    self.faceBookFriendsButton.clipsToBounds = YES;
    self.faceBookFriendsButton.layer.borderColor = buttonColor.CGColor;
    self.faceBookFriendsButton.layer.borderWidth = buttonBorderWidth;
    self.faceBookFriendsButton.layer.cornerRadius = cornerBorderRadius;
    
    [self.inviteFriendsButton setTitleColor:buttonColor forState:UIControlStateNormal];
    self.inviteFriendsButton.clipsToBounds = YES;
    self.inviteFriendsButton.layer.borderColor = buttonColor.CGColor;
    self.inviteFriendsButton.layer.borderWidth = buttonBorderWidth;
    self.inviteFriendsButton.layer.cornerRadius = cornerBorderRadius;
    
    [self.contactButton setTitleColor:buttonColor forState:UIControlStateNormal];
    self.contactButton.clipsToBounds = YES;
    self.contactButton.layer.borderColor = buttonColor.CGColor;
    self.contactButton.layer.borderWidth = buttonBorderWidth;
    self.contactButton.layer.cornerRadius = cornerBorderRadius;
    
    [self.visitWebsiteButton setTitleColor:buttonColor forState:UIControlStateNormal];
    self.visitWebsiteButton.clipsToBounds = YES;
    self.visitWebsiteButton.layer.borderColor = buttonColor.CGColor;
    self.visitWebsiteButton.layer.borderWidth = buttonBorderWidth;
    self.visitWebsiteButton.layer.cornerRadius = cornerBorderRadius;
    
    [self.logoutButton setTitleColor:buttonColor forState:UIControlStateNormal];
    self.logoutButton.clipsToBounds = YES;
    self.logoutButton.layer.borderColor = buttonColor.CGColor;
    self.logoutButton.layer.borderWidth = buttonBorderWidth;
    self.logoutButton.layer.cornerRadius = cornerBorderRadius;
    
    self.followUsLabel.textColor = buttonColor;
    
    self.backroundView.image = self.backgorundImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)facebookFriendsButtonPressed:(id)sender
{
    ALFaceBookFriendsViewController *ffvc = [ALFaceBookFriendsViewController new];
    ffvc.fromTutorial = NO;
    
    [self presentViewController:ffvc animated:YES completion:nil];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inviteFriendsButtonPressed:(id)sender
{
    
}

- (IBAction)contactButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kALMoreBanterSupportEmail]];
}

- (IBAction)visitWebsiteButtonPressed:(id)sender
{
    [self presentWebviewWithURL:kALMoreWebsiteUrl];
}

- (IBAction)logoutButtonPressed:(id)sender
{
    ALUser *currentUser = [ALUserManager.manager currentUser];
    if (currentUser.profileId) {
        // user is a facebook user
        [ALFaceBookManager.manager signOut];
    }
    
    [ALUserManager.manager setUserSignedIn:NO];
}

- (IBAction)facebookButtonPressed:(id)sender
{
    NSURL *facebookURL = [NSURL URLWithString:kALMoreFaceBookAppUrl];
    
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [self presentWebviewWithURL:kALMoreFaceBookUrl];
    }
    
}

- (IBAction)instagramButtonPressed:(id)sender
{
    [self presentWebviewWithURL:kALMoreInstagramUrl];
}

- (void)presentWebviewWithURL:(NSString *)urlString
{
    ALWebViewController *wvc = [[ALWebViewController alloc] initWithUrlString:urlString];
    wvc.exitBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
