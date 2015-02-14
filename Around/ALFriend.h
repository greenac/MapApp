//
//  ALFriend.h
//  Banter!
//
//  Created by Andre Green on 1/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kALFriendFirstName      @"first_name"
#define kALFriendLastName       @"last_name"
#define kALFriendBanterId       @"banter_id"
#define kALFriendProfileId      @"profile_id"
#define kALFriendDateUpdated    @"date_updated"
#define kALFriendEmail          @"email"
#define kALFriendUser           @"user"
#define kALFriendType           @"type"
#define kALFriendPic            @"pic"

@class ALUser;

@interface ALFriend : NSManagedObject

@property (nonatomic, retain) NSNumber * banterId;
@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * profileId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) ALUser *user;

@end
