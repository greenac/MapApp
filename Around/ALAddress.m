//
//  ALAddress.m
//  Around
//
//  Created by Andre Green on 9/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALAddress.h"

#define kALAddressAddress   @"address"
#define kALAddressCity      @"city"
#define kALAddressZip       @"zip"
#define kALAddressCountry   @"country"
#define kALAddressState     @"state"
#define kALAddressLatitude  @"latitude"
#define kALAddressLongitude @"longitude"

@implementation ALAddress

- (id)init
{
    self = [super init];
    if (self) {
        _address    = [[NSString alloc] init];
        _city       = [[NSString alloc] init];
        _zip        = [[NSString alloc] init];
        _state      = [[NSString alloc] init];
        _country    = [[NSString alloc] init];
        _latitude   = [[NSNumber alloc] init];
        _longitude  = [[NSNumber alloc] init];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)addressDict
{
    self = [super init];
    if (self) {
        _address    = addressDict[kALAddressAddress];
        _city       = addressDict[kALAddressCity];
        _zip        = addressDict[kALAddressZip];
        _country    = addressDict[kALAddressCountry];
        _state      = addressDict[kALAddressState];
        
        NSString *latString = addressDict[kALAddressLatitude];
        NSString *longString = addressDict[kALAddressLongitude];
        _latitude   = @(latString.doubleValue);
        _longitude  = @(longString.doubleValue);
    }
    
    return self;
}

- (CLLocationCoordinate2D)location
{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (BOOL)hasCoordinate
{
    if (self.latitude.floatValue == 0.0f && self.longitude.floatValue == 0.0f) {
        return NO;
    }
    return YES;
}

- (BOOL)isEqualToAddress:(ALAddress *)address
{
    if (![self.address isEqualToString:address.address]) {
        return NO;
    } else if (![self.city isEqualToString:address.city]) {
        return NO;
    } else if (![self.zip isEqualToString:address.city]) {
        return NO;
    } else if (![self.state isEqualToString:address.state]) {
        return NO;
    } else if (self.latitude.floatValue != address.latitude.floatValue) {
        return NO;
    } else if (self.longitude.floatValue != address.longitude.floatValue) {
        return NO;
    }
    
    return YES;
}
@end
