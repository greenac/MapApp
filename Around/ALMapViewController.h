//
//  ALMapViewController.h
//  Around
//
//  Created by Andre Green on 8/21/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALNavViewController.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ALTicketView.h"
#import "ALFilterSlideView.h"
#import "ALProfileTableHeaderView.h"
#import "ALAddCommentView.h"
#import "ALMapManager.h"
#import "ALEventListViewController.h"

@class ALLocationManager,ALDataBaseConnector;

@interface ALMapViewController : ALNavViewController <UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate, ALTicketViewDelegate, MKMapViewDelegate, ALProfileTableHeaderViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, ALAddCommentViewDelegate, ALEventListViewControllerDelegate>

@property (copy) void(^serverCallBack)(NSArray*);
@property (copy) void(^afterTicketShowsBloc)();

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;


- (IBAction)locationButtonPushed:(id)sender;

@end
