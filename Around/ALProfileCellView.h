//
//  ALProfileView.h
//  Banter!
//
//  Created by Andre Green on 9/10/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALComment;

@interface ALProfileCellView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIView *commentBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeLabel;

+ (id)initView;
- (void)setInfoWithComment:(ALComment *)comment;

@end
