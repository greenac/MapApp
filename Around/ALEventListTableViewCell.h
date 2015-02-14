//
//  ALEventListTableViewCell.h
//  Banter!
//
//  Created by Andre Green on 9/8/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALEventListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;

@end
