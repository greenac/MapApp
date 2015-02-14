//
//  ALUser.h
//  Banter!
//
//  Created by Andre Green on 1/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kALUserFirstName    @"first_name"
#define kALUserLastName     @"last_name"
#define kALUserProfileId    @"profile_id"
#define kALUserPassword     @"password"
#define kALUserEmail        @"email"
#define kALUserBanterId     @"banter_id"
#define kALUserProfileUrl   @"profile_url"
#define kALUserCurrentUser  @"current_user"
#define kALUserDateUpdated  @"date_updated"
#define kALUserFriends      @"friends"
#define kALUserType         @"type"
#define kALUserTypeFacebook @"facebook"
#define kALUserTypeBanter   @"banter"
#define kALUserGender       @"gender"
#define kALUserPic          @"pic"

@class ALFriend;

@interface ALUser : NSManagedObject

@property (nonatomic, retain) NSNumber * banterId;
@property (nonatomic, retain) NSNumber * currentUser;
@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * profileId;
@property (nonatomic, retain) NSString * profileUrl;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSSet *friends;
@end

@interface ALUser (CoreDataGeneratedAccessors)

- (void)addFriendsObject:(ALFriend *)value;
- (void)removeFriendsObject:(ALFriend *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

@end
