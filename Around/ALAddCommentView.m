//
//  ALAddCommentView.m
//  Banter!
//
//  Created by Andre Green on 10/21/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALAddCommentView.h"

@implementation ALAddCommentView

+ (id)initView
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"ALAddCommentView" owner:self options:nil];
    ALAddCommentView *commentView = [nibViews firstObject];
    if (commentView && [commentView isKindOfClass:[ALAddCommentView class]]) {
        return commentView;
    }
    return nil;
}

- (void)dealloc
{
    self.delegate = nil;
}

- (IBAction)commentButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addCommentView:commentButtonPushed:)]) {
        [self.delegate addCommentView:self commentButtonPushed:sender];
    }
}

@end
