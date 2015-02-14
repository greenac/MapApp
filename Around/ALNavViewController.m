//
//  ALNavViewController.m
//  Banter!
//
//  Created by Andre Green on 1/13/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "ALNavViewController.h"
#import "ALSegues.h"
#import "ALMapViewController.h"
#import "ALMoreViewController.h"
#import "ALEventListViewController.h"
#import "ALMapManager.h"
#import "ALNavigationManager.h"
#import "ALFilterViewController.h"
#import "ALProfilePicManager.h"

#define kALNavVCStopViewTag 83202

@interface ALNavViewController ()

@property (nonatomic, strong) ALNavigationManager *navigationManager;
@property (nonatomic, assign) ALNavigationButton previouslySelectedButton;

@end

@implementation ALNavViewController

- (void)viewDidLoad {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    self.navigationManager = [ALNavigationManager manager];
    self.previouslySelectedButton = ALNavigationButtonNone;
    [self setUpButtons];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpButtons
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.moreBarButton = [[UIBarButtonItem alloc] initWithImage:nil
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(moreButtonPushed:)];
    [self setButtonImage:self.moreBarButton isSelected:[self isButtonSelected:self.moreBarButton]];
    self.navigationItem.leftBarButtonItem = self.moreBarButton;
    
    self.filterBarButton = [[UIBarButtonItem alloc] initWithImage:nil
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(filterButtonPushed:)];
    [self setButtonImage:self.filterBarButton isSelected:[self isButtonSelected:self.filterBarButton]];
    self.navigationItem.rightBarButtonItem = self.filterBarButton;
    
    UIImage *listButtonImage = [UIImage imageNamed:@"list"];
    UIImage *listButtonImageSelected = [UIImage imageNamed:@"list_selected"];
    self.eventListButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      listButtonImage.size.width,
                                                                      listButtonImage.size.height)];
    [self.eventListButton addTarget:self
                             action:@selector(eventListButtonPushed:)
                   forControlEvents:UIControlEventTouchDown];
    [self.eventListButton setImage:listButtonImageSelected forState:UIControlStateHighlighted];
    [self.eventListButton setImage:listButtonImage forState:UIControlStateNormal];
    self.eventListButton.highlighted = [self isButtonSelected:self.eventListButton];
    self.navigationItem.titleView = self.eventListButton;
}

- (BOOL)isButtonSelected:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    BOOL isSelected = NO;
    switch (self.navigationManager.selectedNavigationButton) {
        case ALNavigationButtonMore:
            isSelected = sender == self.moreBarButton;
            break;
        case ALNavigationButtonFilter:
            isSelected = sender == self.filterBarButton;
            break;
        case ALNavigationButtonEventList:
            isSelected = sender == self.eventListButton;
        default:
            break;
    }
    
    return isSelected;
}

- (void)setButtonImage:(id)sender isSelected:(BOOL)isSelected
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (sender == self.eventListButton) {
        self.eventListButton.highlighted = isSelected;
    } else if (sender == self.moreBarButton) {
        if (isSelected) {
            UIImage *moreButtonImageSelected = [[UIImage imageNamed:@"more_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self.moreBarButton setImage:moreButtonImageSelected];
        } else {
            UIImage *moreButtonImage = [[UIImage imageNamed:@"more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self.moreBarButton setImage:moreButtonImage];
        }
    } else if (sender == self.filterBarButton){
        if (isSelected) {
            UIImage *filterButtonImageSelected = [[UIImage imageNamed:@"filter_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self.filterBarButton setImage:filterButtonImageSelected];
        } else {
            UIImage *filterButtonImage = [[UIImage imageNamed:@"filter"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [self.filterBarButton setImage:filterButtonImage];
        }
    }
}

- (void)moreButtonPushed:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (self.navigationManager.selectedNavigationButton == ALNavigationButtonMore) {
        [self.navigationManager updateSelectedButton:ALNavigationButtonNone];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        
        if (self.navigationManager.selectedNavigationButton == ALNavigationButtonFilter) {
            [self filterButtonPushed:self.filterBarButton];
        }
        
        [self.navigationManager updateSelectedButton:ALNavigationButtonMore];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:kALMoreViewController];
        
        [self.navigationController pushViewController:mvc animated:YES];
    }
}

- (void)filterButtonPushed:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (self.navigationManager.selectedNavigationButton == ALNavigationButtonFilter) {
        [self.navigationManager updateSelectedButton:self.previouslySelectedButton];
        self.previouslySelectedButton = ALNavigationButtonNone;
        [self setButtonImage:self.filterBarButton isSelected:NO];
        [self removeFilterViewController];
    } else {
        self.previouslySelectedButton = [ALNavigationManager.manager selectedNavigationButton];
        [self.navigationManager updateSelectedButton:ALNavigationButtonFilter];
        [self setButtonImage:self.filterBarButton isSelected:YES];
        [self moveToFilterViewController];
    }
}

- (void)eventListButtonPushed:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (self.navigationManager.selectedNavigationButton == ALNavigationButtonEventList) {
        [self.navigationManager updateSelectedButton:ALNavigationButtonNone];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else if (self.previouslySelectedButton == ALNavigationButtonEventList &&
               self.navigationManager.selectedNavigationButton == ALNavigationButtonFilter) {
        [self.navigationManager updateSelectedButton:ALNavigationButtonNone];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else if (self.navigationManager.selectedNavigationButton == ALNavigationButtonFilter){
        [self filterButtonPushed:self.filterBarButton];
        [self.navigationManager updateSelectedButton:ALNavigationButtonNone];
        [self eventListButtonPushed:sender];
    }  else {
        [self.navigationManager updateSelectedButton:ALNavigationButtonEventList];
        ALEventListViewController *elvc = [[ALEventListViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:elvc animated:YES];
    }
}

- (void)moveToFilterViewController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    UIView *blockView = [[UIView alloc] initWithFrame:self.view.bounds];
    blockView.tag = kALNavVCStopViewTag;
    blockView.userInteractionEnabled = YES;
    [self.view addSubview:blockView];
    
    NSArray *filterOrder = [ALMapManager.manager eventFilterOrder];
    UIImage *imageForYSpacer = [ALProfilePicManager.manager iconForName:filterOrder[0][0]
                                                               iconType:ALEventIconTypeFilter
                                                               isActive:YES];
    CGFloat viewHeight = kALFilterVCYPadding + imageForYSpacer.size.height + kALFilterVCYSpacing;
    NSUInteger counter = 0;
    for (NSUInteger i=0; i < filterOrder.count-1; i++) {
        NSArray *filterArray = filterOrder[i];
        for (NSUInteger j=0; j < filterArray.count; j++) {
            if (counter == kALFilterVCMaxColumns) {
                viewHeight += imageForYSpacer.size.height + kALFilterVCYSpacing;
            }
            
            counter++;
        }
        
    }
    
    // adjust height for occupancy
    viewHeight += 2.2f*imageForYSpacer.size.height;
    
    static CGFloat viewWidth = 280.0f;
    CGFloat xSpacer = .5*(self.view.bounds.size.width - viewWidth);
    
    ALFilterViewController *fvc = [ALFilterViewController new];
    fvc.view.frame = CGRectMake(xSpacer,
                                self.navigationController.navigationBar.frame.origin.y - viewHeight,
                                viewWidth,
                                viewHeight);
    [self addChildViewController:fvc];
    [self.view addSubview:fvc.view];
    [self.view bringSubviewToFront:fvc.view];
    [fvc didMoveToParentViewController:self];
    
    [UIView animateWithDuration:.35 animations:^{
        fvc.view.frame = CGRectMake(xSpacer,
                                    CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                    viewWidth,
                                    viewHeight);
    } completion:nil];
}

- (void)removeFilterViewController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    UIView *blockView;
    for (UIView *view in self.view.subviews) {
        if (view.tag == kALNavVCStopViewTag) {
            blockView = view;
            break;
        }
    }
    
    [blockView removeFromSuperview];
    
    ALFilterViewController *fvc;
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isMemberOfClass:[ALFilterViewController class]]) {
            fvc = (ALFilterViewController *)vc;
        }
    }
    
    [UIView animateWithDuration:.35 animations:^{
        CGFloat offset = -fvc.view.frame.size.height - self.navigationController.navigationBar.bounds.size.height;
        fvc.view.frame = CGRectOffset(fvc.view.frame,
                                      0.0f,
                                      offset);
    } completion:^(BOOL finished) {
        [fvc.view removeFromSuperview];
        [fvc removeFromParentViewController];
    }];
}

@end
