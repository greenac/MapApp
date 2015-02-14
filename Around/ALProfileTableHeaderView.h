//
//  ALProfileTableHeaderView.h
//  Banter!
//
//  Created by Andre Green on 9/11/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALProfileTableHeaderViewDelegate;

@interface ALProfileTableHeaderView : UIView

@property (weak, nonatomic) IBOutlet UILabel *address1Label;
@property (weak, nonatomic) IBOutlet UILabel *address2Label;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *yelpRatingImageView;
@property (weak, nonatomic) IBOutlet UILabel *openTodayHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *openTodayLabel;
@property (weak, nonatomic) id <ALProfileTableHeaderViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *yelpLogoImageView;

+ (id)initView;

@end


@protocol ALProfileTableHeaderViewDelegate <NSObject>

- (void)profileTableHeaderViewPhoneNumberLabelTouched:(ALProfileTableHeaderView*)profileHeaderView;
- (void)profileTableHeaderYelpLogoTouched:(ALProfileTableHeaderView *)profileHeaderView;
- (void)profileTableHeaderViewAddressLabelTouched:(ALProfileTableHeaderView *)profileHeaderView;

@end