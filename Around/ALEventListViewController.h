//
//  ALEventListViewController.h
//  Banter!
//
//  Created by Andre Green on 9/8/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALNavViewController.h"
#import <UIKit/UIKit.h>
#import "ALTicketView.h"
#import <MapKit/MapKit.h>

@class ALMapManager, ALEventListViewController, ALMapAnnotation;

@protocol ALEventListViewControllerDelegate <NSObject>

- (void)eventListViewController:(ALEventListViewController *)viewController hadAnnotationSelected:(ALMapAnnotation *)annotation;

@end

@interface ALEventListViewController : ALNavViewController <UITableViewDataSource, UITableViewDelegate, ALTicketViewDelegate>

@property (nonatomic, weak) id <ALEventListViewControllerDelegate> delegate;

@end
