//
//  ALEventListTableViewController.h
//  Banter!
//
//  Created by Andre Green on 9/8/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALEventListTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)NSArray *annotations;
@end
