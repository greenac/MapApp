//
//  ALFriendCircleView.h
//  Banter!
//
//  Created by Andre Green on 1/14/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALFriendCircleView : UIView


@property (nonatomic, strong) UIImageView *picView;
@property (nonatomic, strong) UILabel *picLabel;

- (id)initWithFrame:(CGRect)frame pic:(UIImage *)pic name:(NSString *)name;
- (void)getPictureForUsername:(NSString *)username;

@end
