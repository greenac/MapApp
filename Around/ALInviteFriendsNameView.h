//
//  ALInviteFriendsNameView.h
//  Banter!
//
//  Created by Andre Green on 12/2/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALInviteFriendsNameView;

@protocol ALInviteFriendsNameViewDelegate <NSObject>

- (void)inviteFriendsNameViewTouched:(ALInviteFriendsNameView *)nameView;

@end

@interface ALInviteFriendsNameView : UIView

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *xImageView;
@property (nonatomic, weak) id <ALInviteFriendsNameViewDelegate> delegate;

@end
