//
//  ALFriendCircleView.m
//  Banter!
//
//  Created by Andre Green on 1/14/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "ALFriendCircleView.h"
#import <QuartzCore/QuartzCore.h>
#import "ALProfilePicManager.h"

#define kALFriendCircleViewDiameter 75.0f

@implementation ALFriendCircleView

- (id)initWithFrame:(CGRect)frame pic:(UIImage *)pic name:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self) {
        _picView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 kALFriendCircleViewDiameter,
                                                                 kALFriendCircleViewDiameter)];
        _picView.image = pic;

        _picLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                             _picView.bounds.size.height + 5.0f,
                                                             frame.size.width,
                                                             frame.size.height - _picView.bounds.size.height - 5.0f)];
        _picLabel.text = name;
        _picLabel.font = [UIFont systemFontOfSize:9.0f];
        _picLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.picView.frame = CGRectMake(.5*self.bounds.size.width - .5*self.picView.bounds.size.width,
                                    0.0f,
                                    self.picView.bounds.size.width,
                                    self.picView.bounds.size.height);
    self.picView.layer.cornerRadius = .5*kALFriendCircleViewDiameter;
    self.picView.clipsToBounds = YES;
    
    [self addSubview:self.picView];
    [self addSubview:self.picLabel];
}

- (void)getPictureForUsername:(NSString *)username
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __weak typeof (self)weakself = self;
        [ALProfilePicManager.manager profilePicForUser:username withCompletion:^(UIImage *pic) {
            if (!pic) {
                return;
            }
            __strong typeof (weakself)strongself = weakself;
            dispatch_async(dispatch_get_main_queue(), ^{
                strongself.picView.image = pic;
                [strongself setNeedsDisplay];
            });
        }];
    });
}

@end
