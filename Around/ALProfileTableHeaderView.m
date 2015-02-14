//
//  ALProfileTableHeaderView.m
//  Banter!
//
//  Created by Andre Green on 9/11/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALProfileTableHeaderView.h"

@implementation ALProfileTableHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)initView
{
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"ALProfileTableHeaderView" owner:self options:nil];
    ALProfileTableHeaderView *headerView = [nibViews firstObject];
    if (headerView && [headerView isKindOfClass:[ALProfileTableHeaderView class]]) {
        return headerView;
    }
    return nil;
}

- (void)dealloc
{
    self.delegate = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneNumberLabelTouched)];
    tgr.numberOfTapsRequired = 1;
    self.phoneNumberLabel.userInteractionEnabled = YES;
    [self.phoneNumberLabel addGestureRecognizer:tgr];
    
    UITapGestureRecognizer *logoTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yelpLogoTouched)];
    logoTgr.numberOfTapsRequired = 1;
    self.yelpLogoImageView.userInteractionEnabled = YES;
    [self.yelpLogoImageView addGestureRecognizer:logoTgr];
    
    UITapGestureRecognizer *tgrAddress1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressLabelTouched)];
    tgrAddress1.numberOfTapsRequired = 1;
    self.address1Label.userInteractionEnabled = YES;
    [self.address1Label addGestureRecognizer:tgrAddress1];
    
    UITapGestureRecognizer *tgrAddress2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressLabelTouched)];
    tgrAddress2.numberOfTapsRequired = 1;
    self.address2Label.userInteractionEnabled = YES;
    [self.address2Label addGestureRecognizer:tgrAddress2];
}

- (void)phoneNumberLabelTouched
{
    if ([self.delegate respondsToSelector:@selector(profileTableHeaderViewPhoneNumberLabelTouched:)]) {
        [self.delegate profileTableHeaderViewPhoneNumberLabelTouched:self];
    }
}

- (void)yelpLogoTouched
{
    if ([self.delegate respondsToSelector:@selector(profileTableHeaderYelpLogoTouched:)]) {
        [self.delegate profileTableHeaderYelpLogoTouched:self];
    }
}

- (void)addressLabelTouched
{
    if ([self.delegate respondsToSelector:@selector(profileTableHeaderViewAddressLabelTouched:)]) {
        [self.delegate profileTableHeaderViewAddressLabelTouched:self];
    }
}

@end
