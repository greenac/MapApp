//
//  ALInviteFriendsNameView.m
//  Banter!
//
//  Created by Andre Green on 12/2/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALInviteFriendsNameView.h"
#import <QuartzCore/QuartzCore.h>

#define kALInviteFriendsNameViewXSpacer 5.0f
#define kALBanterGreen [UIColor colorWithRed:3.0f/255.0f green:177.0f/255.0f blue:146.0/255.0f alpha:1.0f]

@implementation ALInviteFriendsNameView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _xImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"invite_friends_x"]];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                               0.0f,
                                                               frame.size.width - _xImageView.frame.size.width - 2*kALInviteFriendsNameViewXSpacer,
                                                               frame.size.height)];
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        tgr.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tgr];
        
        [self addSubview:_xImageView];
        [self addSubview:_nameLabel];
    }
    
    
    return self;
}

- (void)layoutSubviews
{
    self.backgroundColor = kALBanterGreen;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 4.0f;
    
    self.nameLabel.frame = CGRectMake(kALInviteFriendsNameViewXSpacer,
                                      0.0f,
                                      self.nameLabel.frame.size.width,
                                      self.nameLabel.frame.size.height);
    self.nameLabel.font = [UIFont systemFontOfSize:11.0f];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    
    self.xImageView.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame),
                                       .5*(self.frame.size.height - self.xImageView.frame.size.height),
                                       self.xImageView.frame.size.width,
                                       self.xImageView.frame.size.height);
    
    
}

- (void)tapped
{
    if ([self.delegate respondsToSelector:@selector(inviteFriendsNameViewTouched:)]) {
        [self.delegate inviteFriendsNameViewTouched:self];
    }
}

@end
