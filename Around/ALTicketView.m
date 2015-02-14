//
//  ALTicketView.m
//  Around
//
//  Created by Andre Green on 9/1/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALTicketView.h"
#import "ALMapAnnotation.h"
#import "ALEvent.h"

@implementation ALTicketView

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
    
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"ALTicketView" owner:self options:nil];
    ALTicketView *ticketView = [nibViews firstObject];
    if (ticketView &&  [ticketView isKindOfClass:[ALTicketView class]]) {
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:ticketView
                                                                              action:@selector(ticketViewTappedOnce:)];
        [ticketView addGestureRecognizer:tgr];
        return ticketView;
    }
    return nil;
}

- (void)dealloc
{
    self.delegate = nil;
}

- (void)removeTapGestureRecognizer
{
    for (UIGestureRecognizer *gr in self.gestureRecognizers) {
        if ([gr isMemberOfClass:[UITapGestureRecognizer class]]) {
            [self removeGestureRecognizer:gr];
            break;
        }
    }
}

- (void)setUpWithAnnotation:(ALMapAnnotation *)annotation image:(UIImage *)image
{
    self.annotation = annotation;
    NSString *distanceString = [NSString stringWithFormat:@"%.1f mi", annotation.event.distanceToUser.floatValue/1609.34f];
    self.iconImageView.image = image;
    self.titleLabel.text = NSLocalizedString(annotation.title, nil);
    self.checkInTimeLabel.text = NSLocalizedString([annotation.event hoursForToday], nil);
    self.messageLabel.text = NSLocalizedString(annotation.event.message, nil);
    self.distanceLabel.text = NSLocalizedString(distanceString, nil);
}

- (void)ticketViewTappedOnce:(UITapGestureRecognizer *)tgr
{
    if ([self.delegate respondsToSelector:@selector(ticketViewTapped:)]) {
        [self.delegate ticketViewTapped:self];
    }
}

- (IBAction)inviteFriendsButtonPushed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(inviteButtonPushedOnTicketView:)]) {
        [self.delegate inviteButtonPushedOnTicketView:self];
    }
}


@end
