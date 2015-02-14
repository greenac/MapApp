//
//  ALDateFormatter.h
//  Banter!
//
//  Created by Andre Green on 11/30/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//
//  Class sets date to string formate yyyy-MM-dd HH:mm:ss
//  Will make this
#import <Foundation/Foundation.h>

@interface ALDateFormatter : NSObject

+ (instancetype)formatter;
- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)dateString;
- (void)setZoneToUTC;
- (void)setZoneToLocal;

@end
