//
//  ALFilterSlideView.m
//  Banter!
//
//  Created by Andre Green on 9/7/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALFilterSlideView.h"

#define kALFilterFoodTruckButtonIndex   0
#define kALFilterLiveMusicButtonIndex   1
#define kALFilterHappyHourButtonIndex   2
#define kALFilterDurration              .1f
#define kALFilterSpacer                 15.0f
@implementation ALFilterSlideView

- (id)init
{
    UIImage *foodTruckImage = [UIImage imageNamed:@"ft_selected"];
    CGRect frame = CGRectMake(0.0f, 0.0f, 3.0f*foodTruckImage.size.width + 3*kALFilterSpacer, foodTruckImage.size.height);
    self = [self initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *foodTruckImage = [UIImage imageNamed:@"ft_selected"];
        UIImage *liveMusicImage = [UIImage imageNamed:@"lm_selected"];
        UIImage *happyHourImage = [UIImage imageNamed:@"hh_selected"];
        UIImage *foodTruckImageUnselected = [UIImage imageNamed:@"ft_empty"];
        UIImage *liveMusicImageUnselected = [UIImage imageNamed:@"lm_empty"];
        UIImage *happyHourImageUnselected = [UIImage imageNamed:@"hh_empty"];
        
        _stageFrame0 = CGRectMake(frame.size.width - foodTruckImage.size.width - kALFilterSpacer, 0.0f, foodTruckImage.size.width, foodTruckImage.size.height);
        _stageFrame1 = CGRectMake(_stageFrame0.origin.x - _stageFrame0.size.width - kALFilterSpacer, 0.0f, _stageFrame0.size.width, _stageFrame0.size.height);
        _stageFrame2 = CGRectMake(_stageFrame1.origin.x - _stageFrame1.size.width - kALFilterSpacer, 0.0f, _stageFrame1.size.width, _stageFrame1.size.height);
        
        _foodTruckButton = [[UIButton alloc] initWithFrame:_stageFrame0];
        [_foodTruckButton addTarget:self action:@selector(foodTruckButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [_foodTruckButton setImage:foodTruckImage forState:UIControlStateSelected];
        [_foodTruckButton setImage:foodTruckImageUnselected forState:UIControlStateNormal];
        _foodTruckButton.selected = YES;
        
        _liveMusicButton = [[UIButton alloc] initWithFrame:_stageFrame0];
        [_liveMusicButton addTarget:self action:@selector(liveMusicButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [_liveMusicButton setImage:liveMusicImage forState:UIControlStateSelected];
        [_liveMusicButton setImage:liveMusicImageUnselected forState:UIControlStateNormal];
        _liveMusicButton.selected = YES;
        
        _happyHourButton = [[UIButton alloc] initWithFrame:_stageFrame0];
        [_happyHourButton addTarget:self action:@selector(happyHourButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [_happyHourButton setImage:happyHourImage forState:UIControlStateSelected];
        [_happyHourButton setImage:happyHourImageUnselected forState:UIControlStateNormal];
        _happyHourButton.selected = YES;
        
        _filterButtons = [[NSArray alloc] initWithObjects:_foodTruckButton, _liveMusicButton, _happyHourButton, nil];
    }
    return self;
}

- (void)slideOut
{
    for (UIButton *button in self.filterButtons) {
        button.frame = self.stageFrame0;
        button.alpha = 0.0f;
        [self addSubview:button];
    }
    
    [UIView animateWithDuration:kALFilterDurration animations:^{
        self.foodTruckButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kALFilterDurration animations:^{
            self.liveMusicButton.alpha = 1.0f;
            self.liveMusicButton.frame = self.stageFrame1;
            self.happyHourButton.frame = self.stageFrame1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kALFilterDurration animations:^{
                self.happyHourButton.alpha = 1.0f;
                self.happyHourButton.frame = self.stageFrame2;
            }];
        }];
    }];
}

- (void)slideIn
{
    [UIView animateWithDuration:kALFilterDurration animations:^{
        self.happyHourButton.alpha = 0.0f;
        self.happyHourButton.frame = self.stageFrame1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kALFilterDurration animations:^{
            self.liveMusicButton.alpha = 0.0f;
            self.liveMusicButton.frame = self.stageFrame0;
            self.happyHourButton.frame = self.stageFrame0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:kALFilterDurration animations:^{
                self.foodTruckButton.alpha = 0.0f;
            } completion:^(BOOL finished) {
                for (UIButton *button in self.filterButtons) {
                    [button removeFromSuperview];
                }
                
                [self removeFromSuperview];
            }];
            
        }];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)foodTruckButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(filterByFoodTruckSlideView:)]) {
        [self.delegate filterByFoodTruckSlideView:self];
    }
}

- (void)liveMusicButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(filterByLiveMusicSlideView:)]) {
        [self.delegate filterByLiveMusicSlideView:self];
    }
}

- (void)happyHourButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(filterByHappyHourSlideView:)]) {
        [self.delegate filterByHappyHourSlideView:self];
    }
}
@end
