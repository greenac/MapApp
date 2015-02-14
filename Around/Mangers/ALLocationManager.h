//
//  ALLocationManager.h
//  Around
//
//  Created by Andre Green on 8/21/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ALLocationManager : CLLocationManager

typedef NS_ENUM(NSUInteger, ALLocationManagerPermissionState) {
    ALLocationManagerPermissionStateGranted,
    ALLocationManagerPermissionStateDenied
};

//+(id)locationManager;

//@property(nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, assign) ALLocationManagerPermissionState persmissionState;

@end
