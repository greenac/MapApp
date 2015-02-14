//
//  ALTicketView.h
//  Around
//
//  Created by Andre Green on 9/1/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALMapAnnotation;

@protocol ALTicketViewDelegate;

@interface ALTicketView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkInTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) id <ALTicketViewDelegate> delegate;
@property (strong, nonatomic) ALMapAnnotation *annotation;

+ (id)initView;
- (IBAction)inviteFriendsButtonPushed:(id)sender;
- (void)removeTapGestureRecognizer;
- (void)setUpWithAnnotation:(ALMapAnnotation *)annotation image:(UIImage *)image;

@end

@protocol ALTicketViewDelegate <NSObject>

- (void)commentButtonPushedTicketView:(ALTicketView*)ticketView;
- (void)inviteButtonPushedOnTicketView:(ALTicketView*)ticketView;
- (void)ticketViewTapped:(ALTicketView *)ticketView;

@end