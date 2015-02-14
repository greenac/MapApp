//
//  ALAddCommentView.h
//  Banter!
//
//  Created by Andre Green on 10/21/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALAddCommentViewDelegate;

@interface ALAddCommentView : UIView

@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) id <ALAddCommentViewDelegate> delegate;

+ (id)initView;
- (IBAction)commentButtonPressed:(id)sender;
@end


@protocol ALAddCommentViewDelegate <NSObject>

- (void)addCommentView:(ALAddCommentView *)commentView commentButtonPushed:(UIButton *)button;

@end