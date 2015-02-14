//
//  ALDateFormatter.m
//  Banter!
//
//  Created by Andre Green on 11/30/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALDateFormatter.h"

@interface ALDateFormatter()

@property (nonatomic, strong) NSDateFormatter *df;

@end

@implementation ALDateFormatter

- (id)init
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        _df = [[NSDateFormatter alloc] init];
        [_df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    return self;
}

+ (instancetype)formatter
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static ALDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[self alloc] init];
    });
    
    return dateFormatter;
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (date) {
        return [self.df stringFromDate:date];
    }
    return nil;
}

-(NSDate *)dateFromString:(NSString *)dateString
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [self.df dateFromString:dateString];
}

- (void)setZoneToLocal
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.df setTimeZone:[NSTimeZone localTimeZone]];
}

- (void)setZoneToUTC
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
}

@end
