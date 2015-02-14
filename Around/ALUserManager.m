//
//  ALUserManager.m
//  Banter!
//
//  Created by Andre Green on 10/4/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALUserManager.h"
#import "ALAppDelegate.h"
#import "ALUser.h"
#import "ALFriend.h"
#import "ALUrls.h"
#import "ALUserDefaults.h"
#import "ALMixPanelManager.h"
#import "ALFaceBookManager.h"
#import "ALProfilePicManager.h"

#define kALUserManagerEntityUser                        @"ALUser"
#define kALUserManagerEntityFriend                      @"ALFriend"
#define kALUserManagerNoValue                           @""
#define kALUserManagerTimeOut                           30


@interface ALUserManager()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end


@implementation ALUserManager

+ (id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static ALUserManager *userManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userManager = [[self alloc] init];
    });
    
    return userManager;
}

- (id)init
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        _context        = ((ALAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
    return self;
}

- (NSDictionary *)userAsDictionary:(ALUser *)user
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSMutableArray *friends = [NSMutableArray new];
    for (ALFriend *friend in user.friends) {
        [friends addObject:[self friendAsDictionary:friend]];
    }
    
    NSMutableDictionary *userDict = [NSMutableDictionary new];
    [self insertIntoDictionary:userDict value:user.firstName key:kALUserFirstName];
    [self insertIntoDictionary:userDict value:user.lastName key:kALUserLastName];
    [self insertIntoDictionary:userDict value:user.profileId key:kALUserProfileId];
    [self insertIntoDictionary:userDict value:user.password key:kALUserPassword];
    [self insertIntoDictionary:userDict value:user.email key:kALUserEmail];
    [self insertIntoDictionary:userDict value:user.banterId key:kALUserBanterId];
    [self insertIntoDictionary:userDict value:user.profileUrl key:kALUserProfileUrl];
    [self insertIntoDictionary:userDict value:[self dateAsString:user.dateUpdated] key:kALUserDateUpdated];
    [self insertIntoDictionary:userDict value:user.type key:kALUserType];
    [self insertIntoDictionary:userDict value:friends key:kALUserFriends];

    return userDict;
}

- (NSDictionary *)friendAsDictionary:(ALFriend *)friend
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSMutableDictionary *friendDict = [NSMutableDictionary new];
    [self insertIntoDictionary:friendDict value:friend.banterId key:kALFriendBanterId];
    [self insertIntoDictionary:friendDict value:friend.profileId key:kALFriendProfileId];
    [self insertIntoDictionary:friendDict value:friend.email key:kALFriendEmail];
    [self insertIntoDictionary:friendDict value:friend.type key:kALFriendType];

    return friendDict;
}

- (void)insertIntoDictionary:(NSMutableDictionary *)dictionary value:(id)value key:(id)key
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // this method prepares objects to be sent to server.
    // ONLY user to package information for server.
    // if value is nil, insert a place holder to let server no there is no value
    if (value) {
        [dictionary setObject:value forKey:key];
    } else {
        [dictionary setObject:kALUserManagerNoValue forKey:key];
    }
}

- (void)saveUser:(NSDictionary *)userDictRepresentation saveToServer:(BOOL)saveToServer
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ALUser *currentUser = self.currentUser;
    if (currentUser) {
        [self saveUserFromDictionary:userDictRepresentation];
        [self setUserSignedIn:YES];
        NSLog(@"current user %@", currentUser);
    } else {
        NSMutableDictionary *userDict = userDictRepresentation.mutableCopy;
        
        if (!userDict[kALUserPassword]) {
            NSString *type = userDictRepresentation[kALUserType];
            if ([type isEqualToString:kALUserTypeFacebook]) {
                // create a password for facebook user
                NSString *password = [NSString stringWithFormat:@"%@%@", userDictRepresentation[kALUserProfileId], userDictRepresentation[kALUserEmail]];
                [userDict setObject:password forKey:kALUserPassword];
            }
        }
        
        [self saveUserFromDictionary:userDict];
    }
    
    if (saveToServer) {
        [[ALMixPanelManager manager] sessionStarted];
        [self saveCurrentUserToServerWithCallBack:nil];
        [self getFriendsPics];
    }
}

- (BOOL)userExists:(NSDictionary *)userDict
{
    BOOL exists = NO;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kALUserManagerEntityUser
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (!error && fetchedObjects.count > 0) {
        exists = YES;
    }
    
    return exists;
}

- (ALFriend *)friendWithProfileId:(NSString *)profileId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"profileId == %@", profileId];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kALUserManagerEntityFriend
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (!error && fetchedObjects.count > 0) {
        return [fetchedObjects firstObject];
    }
    
    return nil;
}

- (void)saveUserFromDictionary:(NSDictionary *)userAsDict
{
    ALUser *currentUser = self.currentUser;
    if (!currentUser) {
        currentUser = [NSEntityDescription insertNewObjectForEntityForName:kALUserManagerEntityUser
                                                    inManagedObjectContext:self.context];
    }
    
    for (NSString *key in userAsDict.allKeys) {
        [self savePropertyForName:key forUser:currentUser fromUserDict:userAsDict];
    }
    
    currentUser.currentUser = @(YES);
    [self saveCurrentUser];
}

- (void)saveCurrentUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ALUser *currentUser;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kALUserManagerEntityUser
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    for (ALUser *user in fetchedObjects) {
        if (user.currentUser.boolValue) {
            currentUser = user;
            break;
        }
    }
    
    if (![self.context save:&error]) {
        NSLog(@"Couldn't save current user: %@", [error localizedDescription]);
    }
}

- (void)savePropertyForName:(NSString *)propertyName forUser:(ALUser *)user fromUserDict:(NSDictionary *)userDict
{
    if ([propertyName isEqualToString:kALUserFirstName] && userDict[kALUserFirstName]) {
        user.firstName = userDict[kALUserFirstName];
    } else if ([propertyName isEqualToString:kALUserLastName] && userDict[kALUserLastName]) {
        user.lastName = userDict[kALUserLastName];
    } else if ([propertyName isEqualToString:kALUserProfileId] && userDict[kALUserProfileId]) {
        user.profileId = userDict[kALUserProfileId];
    } else if ([propertyName isEqualToString:kALUserPassword] && userDict[kALUserPassword]) {
        user.password = userDict[kALUserPassword];
    } else if ([propertyName isEqualToString:kALUserEmail] && userDict[kALUserEmail]) {
        user.email = userDict[kALUserEmail];
    } else if ([propertyName isEqualToString:kALUserBanterId] && userDict[kALUserBanterId]) {
        user.banterId = userDict[kALUserBanterId];
    } else if ([propertyName isEqualToString:kALUserProfileUrl] && userDict[kALUserProfileUrl]) {
        user.profileUrl = userDict[kALUserProfileUrl];
    } else if ([propertyName isEqualToString:kALUserCurrentUser] && userDict[kALUserCurrentUser]) {
        user.currentUser = userDict[kALUserCurrentUser];
    } else if ([propertyName isEqualToString:kALUserDateUpdated] && userDict[kALUserDateUpdated]) {
        NSDate *dateUpdate = [self getDateUpdatedFromString:userDict[kALUserDateUpdated]];
        user.dateUpdated = dateUpdate;
    } else if ([propertyName isEqualToString:kALUserType] && userDict[kALUserType]) {
        user.type = userDict[kALUserType];
    } else if ([propertyName isEqualToString:kALUserGender] && userDict[kALUserGender]) {
        user.gender = userDict[kALUserGender];
    } else if ([propertyName isEqualToString:kALUserFriends] && userDict[kALUserFriends]) {
        [self saveFriendsForUser:user fromUserDict:userDict];
    } else if ([propertyName isEqualToString:kALUserPic] && userDict[kALUserPic]) {
        NSString *email = userDict[kALUserEmail];
        NSData *picData = userDict[kALUserPic];
        [ALProfilePicManager.manager saveProfilePic:[UIImage imageWithData:picData] forUser:email];
    }
}

- (void)saveFriendsForUser:(ALUser *)user fromUserDict:(NSDictionary *)userDict
{
    NSMutableDictionary *currentFriends = [NSMutableDictionary new];
    for (ALFriend *friend in user.friends.allObjects) {
        if (friend.profileId) {
            [currentFriends setObject:friend forKey:friend.profileId];
        }
    }
    
    NSArray *friendsDicts = userDict[kALUserFriends];
    for (NSDictionary *friendDict in friendsDicts) {
        
        ALFriend *friend;
        
        NSString *profileId = friendDict[kALFriendProfileId];
        if (currentFriends[profileId]) {
            friend = currentFriends[profileId];
        } else {
            friend = [NSEntityDescription insertNewObjectForEntityForName:kALUserManagerEntityFriend
                                                   inManagedObjectContext:self.context];
            friend.user = user;
        }
        
        for (NSString *key in friendDict) {
            [self savePropertForName:key forFriend:friend fromFriendDict:friendDict];
        };
        
        friend.dateUpdated  = [NSDate date];
    }
    
    [self getFriendsPics];
}

- (void)savePropertForName:(NSString *)propertyName forFriend:(ALFriend *)friend fromFriendDict:(NSDictionary *)friendDict
{
    if ([propertyName isEqualToString:kALFriendFirstName] && friendDict[kALFriendFirstName]) {
        friend.firstName = friendDict[kALFriendFirstName];
    } else if ([propertyName isEqualToString:kALFriendLastName] && friendDict[kALFriendLastName]) {
        friend.lastName = friendDict[kALFriendLastName];
    } else if ([propertyName isEqualToString:kALFriendBanterId] && friendDict[kALFriendBanterId]) {
        friend.banterId = friendDict[kALFriendBanterId];
    } else if ([propertyName isEqualToString:kALFriendProfileId] && friendDict[kALFriendProfileId]) {
        friend.profileId = friendDict[kALFriendProfileId];
    } else if ([propertyName isEqualToString:kALFriendEmail] && friendDict[kALFriendEmail]) {
        friend.email = friendDict[kALFriendEmail];
    } else if ([propertyName isEqualToString:kALFriendType] && friendDict[kALFriendType]) {
        friend.type = friendDict[kALFriendType];
    }
}

- (id)dictionary:(NSDictionary *)dictionary hasValueForKey:(id)key
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([dictionary objectForKey:key]) {
        return dictionary[key];
    }
    return [NSNull null];
}


- (ALUser *)currentUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kALUserManagerEntityUser
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    ALUser *selectedUser;
    for (ALUser *user in fetchedObjects) {
        if (user.currentUser.boolValue) {
            selectedUser = user;
            break;
        }
    }

    return selectedUser;
}

- (void)getFriendsPics
{
    NSArray *friends = self.currentUser.friends.allObjects;
    for (ALFriend *friend in friends) {
        if (friend.email) {
            // check if profile pic is already on disk. If it is not fetch from server.
            [ALProfilePicManager.manager profilePicForUser:friend.email withCompletion:^(UIImage *image) {
                if (!image) {
                    [ALFaceBookManager.manager getPictureForUserId:friend.profileId onCompletion:^(UIImage *pic) {
                        [ALProfilePicManager.manager saveProfilePic:pic forUser:friend.email];
                    }];
                }
            }];
        } else {
            [ALFaceBookManager.manager getPictureForUserId:friend.profileId onCompletion:^(UIImage *pic) {
                [ALProfilePicManager.manager saveProfilePic:pic forUser:friend.email];
            }];
        }
    }
}

- (NSString *)dateAsString:(NSDate *)date
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    
    return [formatter stringFromDate:date];
}

- (NSString *)encodeDataAsBase64:(NSData *)data
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSString *dataAsString = [data base64EncodedStringWithOptions:0];
    return dataAsString;
}

- (NSData *)decodeBase64String:(NSString *)base64String
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    return data;
}

#pragma mark - server calls

- (void)saveCurrentUserToServerWithCallBack:(void (^)(NSNumber *result))callback
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSDictionary *userDict = [self userAsDictionary:self.currentUser];
    NSError *error;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&error];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, SAVE_USER_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"applcations/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:kALUserManagerTimeOut];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:jsonData
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSLog(@"response url %@, encoding %@", response.URL, response.textEncodingName);
                                                          NSNumber *responseNumber = @(ALUserManagerResponseConnectionFailed);
                                                          if (error) {
                                                              NSLog(@"error in user manager verify user callback: %@", error.localizedDescription);
                                                          } else {
                                                              NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                              if (error) {
                                                                  NSLog(@"Error: %@", error.localizedDescription);
                                                              } else {
                                                                  responseNumber = responseDict[@"response"];
                                                                  if (responseNumber.integerValue == ALUserManagerResponseCreationSuccessful ||
                                                                      responseNumber.integerValue == ALUserManagerResponseExists) {
                                                                      NSDictionary *userInfo = responseDict[@"banter_user"];
                                                                      [self saveUser:userInfo saveToServer:NO];
                                                                  }
                                                              }
                                                          }
                                                          
                                                          if (callback) {
                                                              callback(responseNumber);
                                                          }
                                                      }];
    [uploadTask resume];
}

- (void)verifyUserWithEmail:(NSString *)email andPassword:(NSString *)password completion:(void (^)(NSNumber *response))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSDictionary *userDict = @{@"email":email, @"password":password};
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&error];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, AUTHENTICATE_USER_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"applcations/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:kALUserManagerTimeOut];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:jsonData
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSNumber *responseNumber = @(ALUserManagerResponseConnectionFailed);
                                                          if (error) {
                                                              NSLog(@"error in user manager verify user callback: %@", error.localizedDescription);
                                                          } else {
                                                              NSLog(@"response url %@, encoding %@", response.URL, response.textEncodingName);
                                                              NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                              responseNumber = responseDict[@"response"];
                                                            
                                                              if (error) {
                                                                  NSLog(@"error in user manager verify user callback json deserialization: %@", error.localizedDescription);
                                                              } else {
                                                                  if (responseNumber.integerValue == ALUserManagerResponseExists) {
                                                                      NSDictionary *userInfo = responseDict[@"banter_user"];
                                                                      [self saveUser:userInfo saveToServer:NO];
                                                                  }
                                                              }
                                                          }
                                                          
                                                          if (completion) {
                                                              completion(responseNumber);
                                                          }
                                                      }];
    [uploadTask resume];
}

- (BOOL)isUserSignedIn
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:kALUserDefaultsUserSignedIn]) {
        NSDictionary *signedDict = [ud objectForKey:kALUserDefaultsUserSignedIn];
        NSNumber *isSignedIn = signedDict[kALUserDefaultsUserSignedIn];
        return isSignedIn.boolValue;
    }
    
    return NO;
}

- (BOOL)hasUserCompletedTutorial
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:kALUserDefaultsCompletedTutorial]) {
        NSDictionary *completedDict = [ud objectForKey:kALUserDefaultsCompletedTutorial];
        NSNumber *hasCompletedTutorial = completedDict[kALUserDefaultsCompletedTutorial];
        return hasCompletedTutorial.boolValue;
    }
    
    return NO;
}

- (void)setUserSignedIn:(BOOL)isSignedIn
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *userSignedInDict = @{kALUserDefaultsEmail:self.currentUser.email,
                                       kALUserDefaultsUserSignedIn:@(isSignedIn)
                                       };
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:userSignedInDict forKey:kALUserDefaultsUserSignedIn];
    [ud synchronize];
}

- (void)setUserCompletedTutorial:(BOOL)hasCompleted
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *completedTutorialDict = @{kALUserDefaultsEmail:self.currentUser.email,
                                            kALUserDefaultsCompletedTutorial:@(hasCompleted)
                                            };
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:completedTutorialDict forKey:kALUserDefaultsCompletedTutorial];
    [ud synchronize];
}

- (NSData *)convertBase64ToData:(NSString *)base64String
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    return data;
}

- (NSDate *)getDateUpdatedFromString:(NSString *)dateUpdatedString
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!dateUpdatedString) {
        dateUpdatedString = [self stringFromDate:[NSDate date]];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [formatter dateFromString:dateUpdatedString];

    return date;
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

- (ALUser *)checkUser
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kALUserManagerEntityUser
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    return [fetchedObjects firstObject];
}

@end
