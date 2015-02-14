//
//  ALMapTableViewCell.m
//  Around
//
//  Created by Andre Green on 9/1/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALMapTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ALMapTableViewCell

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.picView.layer.cornerRadius = .5*self.picView.bounds.size.width;
    self.commentLabel.layer.cornerRadius = 4.;
}
@end
