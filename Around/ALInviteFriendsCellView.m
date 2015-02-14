//
//  ALInviteFriendsCellView.m
//  Banter!
//
//  Created by Andre Green on 10/8/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALInviteFriendsCellView.h"

@implementation ALInviteFriendsCellView

+ (id)initView
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"ALInviteFriendsCellView" owner:self options:nil];
    ALInviteFriendsCellView *inviteView = [nibViews firstObject];
    if (inviteView &&  [inviteView isKindOfClass:[ALInviteFriendsCellView class]]) {
        return inviteView;
    }
    
    return nil;
}

- (IBAction)inviteFriendButtonPushed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(friendsViewInviteButtonPushed:)]) {
        [self.delegate friendsViewInviteButtonPushed:self];
    }
}

@end
