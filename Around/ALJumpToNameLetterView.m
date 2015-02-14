//
//  ALJumpToNameLetterView.m
//  Banter!
//
//  Created by Andre Green on 10/9/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALJumpToNameLetterView.h"

@implementation ALJumpToNameLetterView

- (id)initWithLetter:(NSString *)letter andSize:(CGSize)size
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    if (self) {
        _letter = letter;
        CGFloat yOffset = 3.0f;
        _letterButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                   yOffset,
                                                                   self.bounds.size.width,
                                                                   self.bounds.size.height - 2*yOffset)];
        [_letterButton setTitle:_letter forState:UIControlStateNormal];
        _letterButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_letterButton setTitleColor:[UIColor grayColor]
                            forState:UIControlStateNormal];
        [_letterButton addTarget:self
                          action:@selector(letterButtonPushed)
                forControlEvents:UIControlEventTouchDown];
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self addSubview:self.letterButton];
}

- (void)letterButtonPushed
{
    if ([self.delegate respondsToSelector:@selector(jumpToLetterViewSelected:)]) {
        [self.delegate jumpToLetterViewSelected:self];
    }
}
@end
