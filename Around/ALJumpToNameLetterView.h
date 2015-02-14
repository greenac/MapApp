//
//  ALJumpToNameLetterView.h
//  Banter!
//
//  Created by Andre Green on 10/9/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALJumptToLetterViewDelegate;

@interface ALJumpToNameLetterView : UIView

- (id)initWithLetter:(NSString *)letter andSize:(CGSize)size;

@property (nonatomic, copy) NSString *letter;
@property (nonatomic, strong) UIButton *letterButton;
@property (nonatomic, weak) id <ALJumptToLetterViewDelegate> delegate;
@end


@protocol ALJumptToLetterViewDelegate <NSObject>

- (void)jumpToLetterViewSelected:(ALJumpToNameLetterView *)letterView;

@end