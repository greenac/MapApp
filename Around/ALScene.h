//
//  ALScene.h
//  Around
//
//  Created by Andre Green on 9/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class ALAddress, ALHours;

@interface ALScene : NSObject

@property(nonatomic, strong)ALAddress *address;
@property(nonatomic, strong)ALHours *hours;
@property(nonatomic, copy)NSString *contact;
@property(nonatomic, copy)NSString *narrative;
@property(nonatomic, copy)NSString *email;
@property(nonatomic, copy)NSString *facebookUrl;
@property(nonatomic, copy)NSString *instragramUrl;
@property(nonatomic, copy)NSString *openTableUrl;
@property(nonatomic, copy)NSString *twitterUrl;
@property(nonatomic, copy)NSString *websiteUrl;
@property(nonatomic, copy)NSString *yelpUrl;
@property(nonatomic, copy)NSString *name;
@property(nonatomic, copy)NSString *type;
@property(nonatomic, copy)NSString *phoneNumber;
@property(nonatomic, copy)NSString *yelpImageUrl;
@property(nonatomic, strong)NSNumber *sceneId;

-(id)initWithDictionary:(NSDictionary*)sceneDict;
- (NSString*)imageNameForYelpImageUrl;

@end
