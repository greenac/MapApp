//
//  ALMapCellView.m
//  Around
//
//  Created by Andre Green on 9/4/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALMapCellView.h"

@implementation ALMapCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.picView.layer.cornerRadius = .5*self.picView.bounds.size.width;
    self.commentLabel.layer.cornerRadius = 4.;
}


@end
