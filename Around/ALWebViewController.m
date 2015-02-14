//
//  ALWebViewController.m
//  Banter!
//
//  Created by Andre Green on 10/28/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALWebViewController.h"

@interface ALWebViewController ()

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) NSString *urlString;

@end

@implementation ALWebViewController

- (id)initWithUrlString:(NSString *)urlString
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _urlString = urlString;
        _webview = [[UIWebView alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(doneButtonPressed:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
    
    self.webview.frame = self.view.bounds;
    self.webview.delegate = self;
    [self.webview loadRequest:request];
    
    [self.view addSubview:self.webview];
}

- (void)doneButtonPressed:(UIBarButtonItem *)doneButton
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.exitBlock) {
        self.exitBlock();
    }
}

#pragma mark - webview delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return YES;
}

@end
