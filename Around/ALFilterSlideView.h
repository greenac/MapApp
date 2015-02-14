//
//  ALFilterSlideView.h
//  Banter!
//
//  Created by Andre Green on 9/7/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALFilterSlideViewDelegate;

@interface ALFilterSlideView : UIView

@property(nonatomic, weak)id <ALFilterSlideViewDelegate>delegate;
@property(nonatomic, strong)NSArray *filterButtons;
@property(nonatomic, strong)UIButton *foodTruckButton;
@property(nonatomic, strong)UIButton *liveMusicButton;
@property(nonatomic, strong)UIButton *happyHourButton;
@property(nonatomic, assign)CGRect stageFrame0;
@property(nonatomic, assign)CGRect stageFrame1;
@property(nonatomic, assign)CGRect stageFrame2;

- (void)slideOut;
- (void)slideIn;

@end

@protocol ALFilterSlideViewDelegate <NSObject>

- (void)filterByFoodTruckSlideView:(ALFilterSlideView*)filterView;
- (void)filterByLiveMusicSlideView:(ALFilterSlideView*)filterView;
- (void)filterByHappyHourSlideView:(ALFilterSlideView*)filterView;

@end