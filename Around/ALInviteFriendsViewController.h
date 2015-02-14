//
//  ALInviteFriendsViewController.h
//  Banter!
//
//  Created by Andre Green on 10/10/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ALInviteFriendsTableViewCell.h"
#import <MessageUI/MessageUI.h>
#import "ALJumpToNameLetterView.h"
#import "ALInviteFriendsNameView.h"

@class ALEvent;

@interface ALInviteFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ALInviteFriendsTableViewCellDelegate, MFMessageComposeViewControllerDelegate, UIScrollViewDelegate, ALJumptToLetterViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, ALInviteFriendsNameViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *addedContactScrollView;
@property (weak, nonatomic) IBOutlet UIView *eventInfoView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteFriendsLabel;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *searchFieldContainerView;
@property (weak, nonatomic) IBOutlet UIButton *exitSearchButton;
@property (weak, nonatomic) IBOutlet UILabel *contactListLabel;
@property (nonatomic, assign) BOOL fromTutorial;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;

@property (nonatomic, strong) ALEvent *event;

- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)exitSearchButtonPressed:(id)sender;

@end

