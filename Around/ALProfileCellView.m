//
//  ALProfileCellView.m
//  Banter!
//
//  Created by Andre Green on 9/10/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALProfileCellView.h"
#import <QuartzCore/QuartzCore.h>
#import "ALComment+Methods.h"
#import "ALProfilePicManager.h"

@implementation ALProfileCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)initView
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"ALProfileCellView" owner:self options:nil];
    ALProfileCellView *cell = [nibViews firstObject];
    if (cell && [cell isKindOfClass:[ALProfileCellView class]]) {
        return cell;
    }
    return nil;
}

- (void)awakeFromNib
{
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.cornerRadius = .5*self.profileImageView.bounds.size.width;
    
    self.commentBackgroundView.clipsToBounds = YES;
    self.commentBackgroundView.layer.cornerRadius = 2.;
}

- (void)setInfoWithComment:(ALComment *)comment
{
    self.nameLabel.text = NSLocalizedString([comment fullName], nil);
    self.commentLabel.text = NSLocalizedString(comment.comment, nil);
    self.commentBackgroundView.backgroundColor = [UIColor whiteColor];
    self.elapsedTimeLabel.text = comment.elapsedTime;
    self.backgroundColor = [UIColor clearColor];
    [self setProfilePicForUsername:comment.username];
}

- (void)setProfilePicForUsername:(NSString *)username
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [ALProfilePicManager.manager profilePicForUser:username withCompletion:^(UIImage *profilePic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.profileImageView.image = profilePic;
                [self.profileImageView setNeedsDisplay];
            });
        }];
    });
}



@end
