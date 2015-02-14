//
//  ALAddress.h
//  Around
//
//  Created by Andre Green on 9/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ALAddress : NSObject

@property(nonatomic, copy)NSString *address;
@property(nonatomic, copy)NSString *city;
@property(nonatomic, copy)NSString *zip;
@property(nonatomic, copy)NSString *state;
@property(nonatomic, copy)NSString *country;
@property(nonatomic, strong)NSNumber *latitude;
@property(nonatomic, strong)NSNumber *longitude;

- (id)initWithDictionary:(NSDictionary*)addressDict;
- (CLLocationCoordinate2D)location;
- (BOOL)hasCoordinate;
- (BOOL)isEqualToAddress:(ALAddress *)address;
@end
