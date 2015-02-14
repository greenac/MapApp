//
//  ALMoreViewController.h
//  Banter!
//
//  Created by Andre Green on 9/25/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALNavViewController.h"
#import <UIKit/UIKit.h>

@interface ALMoreViewController : ALNavViewController

@property (weak, nonatomic) IBOutlet UIButton *faceBookFriendsButton;
@property (weak, nonatomic) IBOutlet UIImageView *backroundView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *visitWebsiteButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *followUsLabel;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic)UIImage *backgorundImage;

- (IBAction)facebookFriendsButtonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
- (IBAction)inviteFriendsButtonPressed:(id)sender;
- (IBAction)contactButtonPressed:(id)sender;
- (IBAction)visitWebsiteButtonPressed:(id)sender;
- (IBAction)logoutButtonPressed:(id)sender;
- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)instagramButtonPressed:(id)sender;


@end
