//
//  ALEventListViewController.m
//  Banter!
//
//  Created by Andre Green on 9/8/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALEventListViewController.h"
#import "ALEventListTableViewCell.h"
#import "ALMapAnnotation.h"
#import "ALEvent.h"
#import "ALScene.h"
#import "ALAddress.h"
#import "ALMapManager.h"
#import "ALTicketView.h"
#import "ALProfilePicManager.h" 
#import "ALNotifications.h"
#import "ALInviteFriendsViewController.h"
#import "ALSegues.h"

@interface ALEventListViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, strong) UIBarButtonItem *moreBarButton;
@property (nonatomic, strong) UIBarButtonItem *filterBarButton;
@property (nonatomic, strong) UIButton *eventListButton;

@end

@implementation ALEventListViewController

- (NSArray *)annotations
{
    if (!_annotations) {
        _annotations = [NSArray new];
    }
    
    return _annotations;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAnnotationsFromMapMananager];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 84.0f;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventsUpdated:)
                                                 name:kALNotificationMapManagerUpdatedAnnotations
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAnnotationsFromMapMananager
{
    ALMapManager *mapManager = [ALMapManager manager];
    self.annotations = [ALMapManager.manager visibleAnnotationsInMapRect:mapManager.visibleRect];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.annotations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ALTicketTableViewCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    ALMapAnnotation *annotation = [self.annotations objectAtIndex:indexPath.row];
    
    UIImage *icon = [ALProfilePicManager.manager
                     iconForEvent:annotation.event
                     iconType:ALEventIconTypeMapPin];
    
    ALTicketView* ticketView = [ALTicketView initView];
    ticketView.delegate = self;
    [ticketView setUpWithAnnotation:annotation image:icon];
    ticketView.topBar.hidden = YES;
    ticketView.backgroundColor = [UIColor clearColor];
    [ticketView removeTapGestureRecognizer];
    
    cell.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:ticketView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(eventListViewController:hadAnnotationSelected:)]) {
        ALMapAnnotation *annotation = self.annotations[indexPath.row];
        [self.delegate eventListViewController:self hadAnnotationSelected:annotation];
    }
}

- (void)eventsUpdated:(NSNotification *)notification
{
    self.annotations = [ALMapManager.manager visibleAnnotations];
    [self.tableView reloadData];
}


- (void)inviteButtonPushedOnTicketView:(ALTicketView *)ticketView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ALInviteFriendsViewController *ifvc = [storyboard instantiateViewControllerWithIdentifier:kALInviteFriendsViewController];
    ifvc.fromTutorial = NO;
    ifvc.event = ticketView.annotation.event;
    
    [self presentViewController:ifvc animated:YES completion:nil];
}

@end