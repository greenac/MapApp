//
//  ALInviteFriendsCellView.h
//  Banter!
//
//  Created by Andre Green on 10/8/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ALInviteFriendsCellViewDelegate;

@interface ALInviteFriendsCellView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) id <ALInviteFriendsCellViewDelegate> delegate;

+ (id)initView;
- (IBAction)inviteFriendButtonPushed:(id)sender;

@end


@protocol ALInviteFriendsCellViewDelegate <NSObject>

- (void)friendsViewInviteButtonPushed:(ALInviteFriendsCellView *)cellView;

@end