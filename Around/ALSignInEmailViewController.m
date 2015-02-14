//
//  ALSignInEmailViewController.m
//  Banter!
//
//  Created by Andre Green on 10/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALSignInEmailViewController.h"
#import "ALSegues.h"
#import <QuartzCore/QuartzCore.h>
#import "ALUserDefaults.h"
#import "ALUserManager.h"
#import "ALUser.h"
#import "ALMixPanelManager.h"
#import "ALWebViewController.h"

#define kALSigninFieldBackgroundColor       [[UIColor whiteColor] colorWithAlphaComponent:.85f]
#define kALSigninEmailPlaceholder           @"EMAIL"
#define kALSigninPasswordPlaceholder        @"PASSWORD"
#define kALSigninConfirmPasswordPlaceholder @"CONFIRM PASSWORD"
#define kALSigninFirstNamePlaceholder       @"FIRST NAME"
#define kALSigninLastNamePlaceholder        @"LAST NAME"
#define kALSigninCornerRadius               2.0f
#define kALSigninMinPasswordLength          6
#define kALSigninAnimationDurration         0.2f
#define kALSigninAlertNoFacebookEmailTag    1042

@interface ALSignInEmailViewController ()

@property (nonatomic, assign) CGRect fieldEndRect;
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, strong) UIView *dismissFieldView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) NSMutableDictionary *fieldFrames;

@end

@implementation ALSignInEmailViewController

- (void)viewDidLoad
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    if (self.showMessageForNoFacebookEmail) {
        [self showAlertForFaceBookUserHasNoEmail];
    }
    
    //set up buttons
    self.banterButton.backgroundColor = kALSigninFieldBackgroundColor;
    self.banterButton.clipsToBounds = YES;
    self.banterButton.layer.cornerRadius = kALSigninCornerRadius;
    self.banterButton.hidden = YES;
    [self.banterButton setTitle:NSLocalizedString(@"LET'S BANTER!", nil) forState:UIControlStateNormal];
    
    self.backButton.backgroundColor = kALSigninFieldBackgroundColor;
    self.backButton.clipsToBounds = YES;
    self.backButton.layer.cornerRadius = kALSigninCornerRadius;
    [self.backButton setTitle:NSLocalizedString(@"BACK", nil) forState:UIControlStateNormal];
    
    // set up profile pic
    UITapGestureRecognizer *picRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePicViewTapped:)];
    picRecognizer.numberOfTapsRequired = 1;

    UIImage *profilePic = [UIImage imageNamed:@"userimage"];

    self.profilePicView.image = profilePic;
    self.profilePicView.userInteractionEnabled = YES;
    self.profilePicView.clipsToBounds = YES;
    self.profilePicView.layer.cornerRadius = self.profilePicView.bounds.size.width/2.0f;
    [self.profilePicView addGestureRecognizer:picRecognizer];
    
    // text field setup
    CGRect fieldSpacerRect = CGRectMake(0.0f, 0.0f, 10.0f, 10.0f);
    UIView *fieldSpacerView1 = [[UIView alloc] initWithFrame:fieldSpacerRect];
    UIView *fieldSpacerView2 = [[UIView alloc] initWithFrame:fieldSpacerRect];
    UIView *fieldSpacerView3 = [[UIView alloc] initWithFrame:fieldSpacerRect];
    UIView *fieldSpacerView4 = [[UIView alloc] initWithFrame:fieldSpacerRect];
    UIView *fieldSpacerView5 = [[UIView alloc] initWithFrame:fieldSpacerRect];
    
    UIFont *fieldFont = [UIFont systemFontOfSize:12.0f];
    NSUInteger returnKeyType = UIReturnKeyNext;
    
    self.confirmPasswordField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.confirmPasswordField.backgroundColor = kALSigninFieldBackgroundColor;
    self.confirmPasswordField.font = fieldFont;
    self.confirmPasswordField.clipsToBounds = YES;
    self.confirmPasswordField.layer.cornerRadius = kALSigninCornerRadius;
    self.confirmPasswordField.placeholder = kALSigninConfirmPasswordPlaceholder;
    self.confirmPasswordField.delegate = self;
    self.confirmPasswordField.leftViewMode = UITextFieldViewModeAlways;
    self.confirmPasswordField.leftView = fieldSpacerView5;
    self.confirmPasswordField.secureTextEntry = YES;
    self.confirmPasswordField.returnKeyType = UIReturnKeyDone;
    self.confirmPasswordField.hidden = self.loginMode;
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.passwordField.backgroundColor = kALSigninFieldBackgroundColor;
    self.passwordField.font = fieldFont;
    self.passwordField.clipsToBounds = YES;
    self.passwordField.layer.cornerRadius = kALSigninCornerRadius;
    self.passwordField.placeholder = kALSigninPasswordPlaceholder;
    self.passwordField.delegate = self;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.leftView = fieldSpacerView4;
    self.passwordField.returnKeyType = (self.loginMode) ? UIReturnKeyDone : returnKeyType;
    self.passwordField.secureTextEntry = YES;
    
    self.emailField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.emailField.backgroundColor = kALSigninFieldBackgroundColor;
    self.emailField.font = fieldFont;
    self.emailField.clipsToBounds = YES;
    self.emailField.layer.cornerRadius = kALSigninCornerRadius;
    self.emailField.placeholder = kALSigninEmailPlaceholder;
    self.emailField.delegate = self;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.leftViewMode = UITextFieldViewModeAlways;
    self.emailField.returnKeyType = returnKeyType;
    self.emailField.leftView = fieldSpacerView3;
    
    self.lastNameField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.lastNameField.backgroundColor = kALSigninFieldBackgroundColor;
    self.lastNameField.font = fieldFont;
    self.lastNameField.clipsToBounds = YES;
    self.lastNameField.layer.cornerRadius = kALSigninCornerRadius;
    self.lastNameField.placeholder = kALSigninLastNamePlaceholder;
    self.lastNameField.delegate = self;
    self.lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.lastNameField.leftViewMode = UITextFieldViewModeAlways;
    self.lastNameField.leftView = fieldSpacerView2;
    self.lastNameField.returnKeyType = returnKeyType;
    self.lastNameField.hidden = self.loginMode;
    
    self.firstNameField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.firstNameField.backgroundColor = kALSigninFieldBackgroundColor;
    self.firstNameField.font = fieldFont;
    self.firstNameField.clipsToBounds = YES;
    self.firstNameField.layer.cornerRadius = kALSigninCornerRadius;
    self.firstNameField.placeholder = kALSigninFirstNamePlaceholder;
    self.firstNameField.delegate = self;
    self.firstNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.firstNameField.leftViewMode = UITextFieldViewModeAlways;
    self.firstNameField.leftView = fieldSpacerView1;
    self.firstNameField.returnKeyType = returnKeyType;
    self.firstNameField.hidden = self.loginMode;
    
    [self.view addSubview:self.confirmPasswordField];
    [self.view addSubview:self.passwordField];
    [self.view addSubview:self.emailField];
    [self.view addSubview:self.lastNameField];
    [self.view addSubview:self.firstNameField];

    self.fieldFrames = [[NSMutableDictionary alloc] initWithDictionary:@{kALSigninFirstNamePlaceholder:[NSValue valueWithCGRect:CGRectZero],
                                                                         kALSigninLastNamePlaceholder:[NSValue valueWithCGRect:CGRectZero],
                                                                         kALSigninEmailPlaceholder:[NSValue valueWithCGRect:CGRectZero],
                                                                         kALSigninPasswordPlaceholder:[NSValue valueWithCGRect:CGRectZero],
                                                                         kALSigninConfirmPasswordPlaceholder:[NSValue valueWithCGRect:CGRectZero]
                                                                         }];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(fieldBackgroundViewTapped:)];
    tgr.numberOfTapsRequired = 1;
    self.dismissFieldView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.dismissFieldView addGestureRecognizer:tgr];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGRect textFieldRect = self.backButton.frame;
    
    self.confirmPasswordField.frame = textFieldRect;
    self.passwordField.frame = textFieldRect;
    self.emailField.frame = textFieldRect;
    self.lastNameField.frame = textFieldRect;
    self.firstNameField.frame = textFieldRect;
    
    CGFloat fieldSpacer = 5.0f;
    __block CGFloat yOffSet = fieldSpacer + textFieldRect.size.height;
    
    [UIView animateWithDuration:.2f animations:^{
        if (!self.loginMode) {
            self.confirmPasswordField.frame = CGRectOffset(textFieldRect, 0.0f, -yOffSet);
            self.fieldFrames[kALSigninConfirmPasswordPlaceholder] = [NSValue valueWithCGRect:self.confirmPasswordField.frame];
            yOffSet += fieldSpacer + textFieldRect.size.height;
        }
        
        self.passwordField.frame = CGRectOffset(textFieldRect, 0.0f, -yOffSet);
        self.fieldFrames[kALSigninPasswordPlaceholder] = [NSValue valueWithCGRect:self.passwordField.frame];
        yOffSet += fieldSpacer + textFieldRect.size.height;
        
        self.emailField.frame = CGRectOffset(textFieldRect, 0.0f, -yOffSet);
        self.fieldFrames[kALSigninEmailPlaceholder] = [NSValue valueWithCGRect:self.emailField.frame];
        yOffSet += fieldSpacer + textFieldRect.size.height;
        
        if (!self.loginMode) {
            self.lastNameField.frame = CGRectOffset(textFieldRect, 0.0f, -yOffSet);
            self.fieldFrames[kALSigninLastNamePlaceholder] = [NSValue valueWithCGRect:self.lastNameField.frame];
            yOffSet += fieldSpacer + textFieldRect.size.height;
            
            self.firstNameField.frame = CGRectOffset(textFieldRect, 0.0f, -yOffSet);
            self.fieldFrames[kALSigninFirstNamePlaceholder] = [NSValue valueWithCGRect:self.firstNameField.frame];
        }
    } completion:^(BOOL finished) {
        self.fieldEndRect = CGRectMake(self.emailField.frame.origin.x,
                                       CGRectGetMaxY(self.profilePicView.frame) + fieldSpacer,
                                       self.emailField.frame.size.width,
                                       self.emailField.frame.size.height);
    }];
}

- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _activityView;
}

- (void)startActivityIndicator
{
    [self.view addSubview:self.activityView];
    
    self.activityView.frame = CGRectMake(self.view.center.x - .5*self.activityView.frame.size.width,
                                         self.profilePicView.frame.origin.y - self.activityView.bounds.size.height - 2.0f,
                                         self.activityView.bounds.size.width,
                                         self.activityView.bounds.size.height);
    [self.activityView startAnimating];
}

- (void)stopActivityIndicator
{
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
}

- (void)signInSuccesful
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [[ALUserManager manager] setUserSignedIn:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[ALUserManager manager] hasUserCompletedTutorial]) {
            [self performSegueWithIdentifier:kALSegueEmailLoginToMap sender:self];
        } else {
            [self performSegueWithIdentifier:kALSegueEmailLoginToTutorial sender:self];
        }
    });
    
    [self startActivityIndicator];
}

- (void)signInFailed
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

    dispatch_async(dispatch_get_main_queue(), ^{
        self.banterButton.enabled = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed", nil)
                                                        message:NSLocalizedString(@"That email address is already in use. Please try again with another address or check your password", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self stopActivityIndicator];
    });
}

- (void)profilePicViewTapped:(UITapGestureRecognizer *)tgr
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)showAlertForFaceBookUserHasNoEmail
{
    if (self.showMessageForNoFacebookEmail) {
        NSString *message = NSLocalizedString(@"Banter requires an email address to work properly. We couldn't find an email attached to your Facebook profile. To fix this you can enable this feature on your facebook account(press 'Help' below if you're not sure not sure how to do this), or sign in with your email.", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Email Detected", nil)
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Sign In With Email"
                                              otherButtonTitles:@"Help", nil];
        alert.tag = kALSigninAlertNoFacebookEmailTag;
        [alert show];
    }
}

- (IBAction)banterButtonPressed:(id)sender
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    self.banterButton.enabled = NO;
    
    [self startActivityIndicator];
    
    if (self.loginMode) {
        [[ALUserManager manager] verifyUserWithEmail:self.email andPassword:self.password completion:^(NSNumber *response) {
            [self handleSignInWithResult:response];
        }];
    } else {
        [self saveUser];
    }
}

- (IBAction)backButtonPressed:(id)sender
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shrinkField:(UITextField *)field durration:(CGFloat)durration isUp:(BOOL)isUp afterAnimationBlock:(void (^)(void))afterAnimationBlock
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    CGRect fieldOriginalFrame = [self getFieldStartFrameForField:field];
    
    [UIView animateWithDuration:durration animations:^{
        field.frame = CGRectMake(field.frame.origin.x,
                                 field.frame.origin.y,
                                 0.0f,
                                 field.frame.size.height);
    } completion:^(BOOL finished) {
        if (isUp) {
            field.frame = CGRectMake(fieldOriginalFrame.origin.x,
                                     fieldOriginalFrame.origin.y,
                                     0.0f,
                                     fieldOriginalFrame.size.height);
        } else {
            field.frame = CGRectMake(self.fieldEndRect.origin.x,
                                     self.fieldEndRect.origin.y,
                                     0.0f,
                                     self.fieldEndRect.size.height);
        }
        
        [self.view bringSubviewToFront:field];
        
        if (afterAnimationBlock) {
            afterAnimationBlock();
        }
    }];
}

- (void)expandField:(UITextField *)field durration:(CGFloat)durration isUp:(BOOL)isUp afterAnimationBlock:(void (^)(void))afterAnimationBlock
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    CGRect fieldFrame = isUp ? self.fieldEndRect : [self getFieldStartFrameForField:field];
    
    [UIView animateWithDuration:durration animations:^{
        field.frame = fieldFrame;
    } completion:^(BOOL finished) {
        [self.view bringSubviewToFront:field];
        
        if (afterAnimationBlock){
            afterAnimationBlock();
        }
    }];
}

- (void)moveFromField:(UITextField *)fromField toField:(UITextField *)toField
{
    [self shrinkField:fromField durration:.2 isUp:YES afterAnimationBlock:^{
        [self expandField:toField durration:.2 isUp:NO afterAnimationBlock:^{
            [toField becomeFirstResponder];
        }];
    }];
}

- (void)moveTextFieldUpWithAnimation:(UITextField *)textField finished:(void(^)(void))completionBlock
{
    self.textField = textField;
    [self.view addSubview:self.dismissFieldView];
    
    [self shrinkField:textField durration:kALSigninAnimationDurration isUp:NO afterAnimationBlock:^{
        [self expandField:textField durration:kALSigninAnimationDurration isUp:YES afterAnimationBlock:completionBlock];
    }];
}

- (void)moveTextFieldDownWithAnimation:(UITextField *)textField finished:(void(^)(void))completionBlock
{
    [self shrinkField:textField durration:kALSigninAnimationDurration isUp:YES afterAnimationBlock:^{
        [self expandField:textField durration:kALSigninAnimationDurration isUp:NO afterAnimationBlock:completionBlock];
    }];
}

- (CGRect)getFieldStartFrameForField:(UITextField *)field
{
    NSValue *fieldFrameValue;
    if (field == self.firstNameField) {
        fieldFrameValue = self.fieldFrames[kALSigninFirstNamePlaceholder];
    } else if (field == self.lastNameField) {
        fieldFrameValue = self.fieldFrames[kALSigninLastNamePlaceholder];
    } else if (field == self.emailField) {
        fieldFrameValue  = self.fieldFrames[kALSigninEmailPlaceholder];
    } else if (field == self.passwordField) {
        fieldFrameValue = self.fieldFrames[kALSigninPasswordPlaceholder];
    } else if (field == self.confirmPasswordField) {
        fieldFrameValue = self.fieldFrames[kALSigninConfirmPasswordPlaceholder];
    } else {
        fieldFrameValue = [NSValue valueWithCGRect:CGRectZero];
    }
    
    return fieldFrameValue.CGRectValue;
}

- (void)fieldBackgroundViewTapped:(UITapGestureRecognizer *)tgr
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.dismissFieldView removeFromSuperview];
    [self.textField resignFirstResponder];
}

- (BOOL)checkEmailAddress:(NSString *)address
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSArray *comonents = [address componentsSeparatedByString:@"@"];
    return comonents.count > 1;
}

- (void)saveUser
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSData *picData = UIImageJPEGRepresentation(self.profilePicView.image, 1.0f);
    NSDictionary *user = @{kALUserFirstName:self.firstName,
                           kALUserLastName:self.lastName,
                           kALUserEmail:self.email,
                           kALUserPassword:self.password,
                           kALUserPic:picData,
                           kALUserType:kALUserTypeBanter
                           };
    
    [[ALUserManager manager] saveUser:user saveToServer:NO];
    [[ALUserManager manager] saveCurrentUserToServerWithCallBack:^(NSNumber *result) {
        [self handleSignInWithResult:result];
    }];
}

- (void)handleSignInWithResult:(NSNumber *)result
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    dispatch_async (dispatch_get_main_queue(), ^{
        if (result.integerValue == ALUserManagerResponseCreationSuccessful ||
            result.integerValue == ALUserManagerResponseExists) {
            [[ALUserManager manager] setUserSignedIn:YES];
            [[ALMixPanelManager manager] sessionStarted];
            if ([[ALUserManager manager] hasUserCompletedTutorial]) {
                [self performSegueWithIdentifier:kALSegueEmailLoginToMap sender:nil];
            } else {
                [self performSegueWithIdentifier:kALSegueEmailLoginToTutorial sender:nil];
            }
        } else {
            NSString *message;
            switch (result.integerValue) {
                case ALUserManagerResponseConnectionFailed:
                    message = NSLocalizedString(@"Banter! could not connect to its network at this time. Please check your connection, or tell us about your problem: contact@thebanterapp.com", nil);
                    break;
                case ALUserManagerResponseDoesNotExist:
                    message = NSLocalizedString(@"Sorry, no user with that user name exists", nil);
                    break;
                case ALUserManagerResponseExistsWrongPassword:
                    message = NSLocalizedString(@"Username and password are not a match. Please check your information and try again.", nil);
                    break;
                default:
                    message = NSLocalizedString(@"Sorry. Banter! couldn't sign you in right now. Please try again or sign in with Facebook", nil);
                    break;
            }
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed To Sign In", nil)
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        self.banterButton.enabled = YES;
        [self stopActivityIndicator];
    });
}

#pragma mark - text field delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self moveTextFieldUpWithAnimation:textField finished:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self moveTextFieldDownWithAnimation:textField finished:nil];
    
    if (textField.text) {
        if (textField == self.passwordField && textField.text.length < kALSigninMinPasswordLength) {
            [self showAlertWithTitle:NSLocalizedString(@"Password Too Short", nil)
                             message:NSLocalizedString(@"Password must be at least 6 characters in length", nil)
                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                        buttonTitles:nil];
        } else if (textField == self.emailField && ![self checkEmailAddress:self.textField.text]) {
            [self showAlertWithTitle:NSLocalizedString(@"Email Not Valid", nil)
                             message:NSLocalizedString(@"Please enter a valid email address", nil)
                   cancelButtonTitle:@"OK"
                        buttonTitles:nil];
        } else if (textField == self.confirmPasswordField && ![self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
            [self showAlertWithTitle:NSLocalizedString(@"Password Don't Match", nil)
                             message:NSLocalizedString(@"Please re-enter your passwords", nil)
                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                        buttonTitles:nil];
        }
    }
    
    if (self.loginMode) {
        if (self.passwordField.text.length >= kALSigninMinPasswordLength &&
            self.emailField.text &&
            [self checkEmailAddress:self.emailField.text]) {
            
            self.password = self.passwordField.text;
            self.email = self.emailField.text;
            
            self.banterButton.hidden = NO;
            self.backButton.hidden = YES;
        } else {
            self.banterButton.hidden = YES;
            self.backButton.hidden = NO;
        }
    } else {
        if (self.firstNameField.text.length > 0 &&
            self.lastNameField.text.length > 0 &&
            self.passwordField.text.length >= kALSigninMinPasswordLength &&
            self.emailField.text &&
            [self checkEmailAddress:self.emailField.text] &&
            [self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
            
            self.firstName = self.firstNameField.text;
            self.lastName = self.lastNameField.text;
            self.password = self.passwordField.text;
            self.email = self.emailField.text;
            
            self.banterButton.hidden = NO;
            self.backButton.hidden = YES;
        } else {
            self.banterButton.hidden = YES;
            self.backButton.hidden = NO;
        }
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.loginMode) {
        if (self.emailField == textField) {
            [self.emailField resignFirstResponder];
            [self.passwordField becomeFirstResponder];
        } else if (self.passwordField == textField) {
            [self.passwordField resignFirstResponder];
        }
    } else {
        if (self.firstNameField == textField) {
            [self.firstNameField resignFirstResponder];
            [self.lastNameField becomeFirstResponder];
        } else if (self.lastNameField == textField) {
            [self.lastNameField resignFirstResponder];
            [self.emailField becomeFirstResponder];
        } else if (self.emailField == textField) {
            [self.emailField resignFirstResponder];
            [self.passwordField becomeFirstResponder];
        } else if (self.passwordField == textField) {
            [self.passwordField resignFirstResponder];
            [self.confirmPasswordField becomeFirstResponder];
        } else if (self.confirmPasswordField == textField) {
            [self.confirmPasswordField resignFirstResponder];
        }
    }
    
    return YES;
}

#pragma mark - alert view delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kALSigninAlertNoFacebookEmailTag) {
        if (buttonIndex == 1) {
            // user has pushed help button
            NSString *banterHelpUrl = @"http://www.thebanterapp.com/support";
            ALWebViewController *wvc = [[ALWebViewController alloc] initWithUrlString:banterHelpUrl];
            wvc.exitBlock = ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            };
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:wvc];
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle buttonTitles:(NSArray *)buttons
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.alertView = [[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:self
                                      cancelButtonTitle:cancelButtonTitle
                                      otherButtonTitles:nil];
    
    if (buttons) {
        for (NSString *buttonTitle in buttons) {
            [self.alertView addButtonWithTitle:buttonTitle];
        }
    }
    
    [self.alertView show];
}

#pragma mark - image picker delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    CGRect drawingRect = CGRectMake(0.0f, 0.0f, 200.0f, 200.0f);
    UIGraphicsBeginImageContext(drawingRect.size);
    [originalImage drawInRect:drawingRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(newImage);
    UIImage *profilePic = [UIImage imageWithData:imageData];

    self.profilePicView.image = profilePic;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
