//
//  ALInviteFriendsTableViewCell.h
//  Banter!
//
//  Created by Andre Green on 10/9/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALInviteFriendsTableViewCellDelegate;

@interface ALInviteFriendsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneNumberLabel;
@property (nonatomic, weak) IBOutlet UIButton *addContactButton;
@property (nonatomic, weak) id <ALInviteFriendsTableViewCellDelegate> delegate;

- (IBAction)addContactButtonPushed:(id)sender;

@end


@protocol ALInviteFriendsTableViewCellDelegate <NSObject>

- (void)inviteFriendsTableViewCellAddContactButtonPushed:(ALInviteFriendsTableViewCell *)cell;

@end