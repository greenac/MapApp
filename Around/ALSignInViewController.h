//
//  ALSignInViewController.h
//  Banter!
//
//  Created by Andre Green on 10/2/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALSignInViewController : UIViewController <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *facebookSignInButton;
@property (weak, nonatomic) IBOutlet UIButton *emailSignInButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (assign, nonatomic) BOOL faceBookUserHasEmail;

- (IBAction)faceBookButtonPushed:(id)sender;
- (IBAction)emailButtonPushed:(id)sender;
- (IBAction)logginButtonPushed:(id)sender;

@end
