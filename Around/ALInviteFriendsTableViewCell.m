//
//  ALInviteFriendsTableViewCell.m
//  Banter!
//
//  Created by Andre Green on 10/9/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALInviteFriendsTableViewCell.h"

@implementation ALInviteFriendsTableViewCell


- (IBAction)addContactButtonPushed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(inviteFriendsTableViewCellAddContactButtonPushed:)]) {
        [self.delegate inviteFriendsTableViewCellAddContactButtonPushed:self];
    }
}

@end
