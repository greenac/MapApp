//
//  ALJumpToContactLetterView.m
//  Banter!
//
//  Created by Andre Green on 10/12/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALJumpToContactLetterView.h"
#import "ALJumpToNameLetterView.h"

@interface ALJumpToContactLetterView()

@property(nonatomic, strong) NSArray *alphabet;

@end

@implementation ALJumpToContactLetterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alphabet = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
                          @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // create letter views.
    
    CGFloat letterHeight = [self letterHeight];
    CGFloat yPos = 0.0f;
    CGSize letterSize = CGSizeMake(self.bounds.size.width, letterHeight);
    for (NSString *letter in self.alphabet) {
        ALJumpToNameLetterView *letterView = [[ALJumpToNameLetterView alloc] initWithLetter:letter
                                                                                  andSize:letterSize];
        letterView.frame = CGRectMake(0.0f, yPos, letterView.bounds.size.width, letterView.bounds.size.height);
        letterView.letter = letter;
        
        [self addSubview:letterView];
        
        yPos += letterView.bounds.size.height;
        
        if ([self.parentController conformsToProtocol:@protocol(ALJumptToLetterViewDelegate)]) {
            UIViewController <ALJumptToLetterViewDelegate> *conformedController = (UIViewController <ALJumptToLetterViewDelegate> *)self.parentController;
            letterView.delegate = conformedController;
        }
    }
}

- (CGFloat)letterHeight
{
    return self.frame.size.height/self.alphabet.count;
}
@end
