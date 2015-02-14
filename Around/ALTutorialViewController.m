//
//  ALTutorialViewController.m
//  Banter!
//
//  Created by Andre Green on 10/6/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALTutorialViewController.h"

@interface ALTutorialViewController ()

@end

@implementation ALTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.backgroundImage) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        backgroundView.image = self.backgroundImage;
        [self.view addSubview:backgroundView];
    }
}

- (UIImage *)backgroundImage
{
    if (!_backgroundImage) {
        _backgroundImage = [UIImage new];
    }
    
    return _backgroundImage;
}

@end
