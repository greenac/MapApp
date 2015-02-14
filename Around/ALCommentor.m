//
//  ALCommentor.m
//  Around
//
//  Created by Andre Green on 9/4/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALCommentor.h"

@implementation ALCommentor

- (id)initWithName:(NSString *)name image:(UIImage *)image comment:(NSString *)comment
{
    self = [super init];
    if (self) {
        _name       = name;
        _comment    = comment;
        _image      = image;
    }
    return self;
}

@end
