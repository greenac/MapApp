//
//  ALSignInEmailViewController.h
//  Banter!
//
//  Created by Andre Green on 10/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALSignInEmailViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *banterButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicView;


@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;

@property (assign, nonatomic) BOOL loginMode;
@property (assign, nonatomic) BOOL showMessageForNoFacebookEmail;

- (IBAction)banterButtonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;

@end
