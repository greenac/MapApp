//
//  ALHours.h
//  Around
//
//  Created by Andre Green on 9/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALHours : NSObject

@property(nonatomic, strong)NSString *monday;
@property(nonatomic, strong)NSString *tuesday;
@property(nonatomic, strong)NSString *wednesday;
@property(nonatomic, strong)NSString *thursday;
@property(nonatomic, strong)NSString *friday;
@property(nonatomic, strong)NSString *saturday;
@property(nonatomic, strong)NSString *sunday;

- (id)initWithDictionary:(NSDictionary*)hoursDict;
- (NSString*)hoursForCurrentDay;
@end
