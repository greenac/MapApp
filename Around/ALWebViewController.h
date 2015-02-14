//
//  ALWebViewController.h
//  Banter!
//
//  Created by Andre Green on 10/28/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALWebViewController : UIViewController <UIWebViewDelegate>

@property (copy) void (^exitBlock)(void);

- (id)initWithUrlString:(NSString *)urlString;

@end
