//
//  ALScene.m
//  Around
//
//  Created by Andre Green on 9/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALScene.h"
#import "ALHours.h"
#import "ALAddress.h"
#import "ALEvent.h"

@implementation ALScene

-(id)initWithDictionary:(NSDictionary *)sceneDict
{
    self = [super init];
    if (self) {
        
        _address            = [[ALAddress alloc] initWithDictionary:sceneDict];
        _hours              = [[ALHours alloc] initWithDictionary:sceneDict];
        _contact            = sceneDict[@"contact"];
        _narrative          = sceneDict[@"description"];
        _email              = sceneDict[@"email"];
        _facebookUrl        = sceneDict[@"facebook_url"];
        _instragramUrl      = sceneDict[@"instagram_url"];
        _openTableUrl       = sceneDict[@"open_table_url"];
        _twitterUrl         = sceneDict[@"twitter_url"];
        _websiteUrl         = sceneDict[@"website_url"];
        _yelpUrl            = sceneDict[@"yelp_url"];
        _name               = sceneDict[@"name"];
        _type               = sceneDict[@"type"];
        _phoneNumber        = sceneDict[@"phone_number"];
        _yelpImageUrl       = sceneDict[@"yelp_image_url"];
        _sceneId            = sceneDict[@"scene_id"];
    }
    
    return self;
}

- (NSString*)imageNameForYelpImageUrl
{
    NSArray *parts = [self.yelpImageUrl componentsSeparatedByString:@"/"];
    if (parts.count > 1) {
        return [parts lastObject];
    }
    return nil;
}
@end
