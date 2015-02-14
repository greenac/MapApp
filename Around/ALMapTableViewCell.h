//
//  ALMapTableViewCell.h
//  Around
//
//  Created by Andre Green on 9/1/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALMapTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end
