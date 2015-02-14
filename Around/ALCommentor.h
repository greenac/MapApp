//
//  ALCommentor.h
//  Around
//
//  Created by Andre Green on 9/4/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALCommentor : NSObject

@property(nonatomic, strong)NSString *comment;
@property(nonatomic, strong)UIImage *image;
@property(nonatomic, strong)NSString *name;

- (id)initWithName:(NSString*)name image:(UIImage*)image comment:(NSString*)comment;
@end
