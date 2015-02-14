//
//  ALFaceBookManager.m
//  Banter!
//
//  Created by Andre Green on 10/4/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "ALFaceBookManager.h"
#import "ALNotifications.h"
#import "ALAppDelegate.h"
#import "ALUserManager.h"
#import "ALFriend.h"
#import "ALUser.h"
#import "ALUserDefaults.h"
#import "ALProfilePicManager.h"

#define kALFaceBookManagerTimeOut   60

@interface ALFaceBookManager()

@property (nonatomic, strong) NSArray *permissions;
@property (nonatomic, strong) NSArray *friendsList;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSData *imageData;

@end

@implementation ALFaceBookManager

+(id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static ALFaceBookManager *facebookManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        facebookManager = [[self alloc] init];
    });
    
    return facebookManager;
}

- (id)init
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        _permissions = @[@"public_profile", @"email", @"user_friends"];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)setUp
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:self.permissions
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (state == FBSessionStateOpen) {
        [self getInfo];
    } else if (state == FBSessionStateClosed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kALNotificationUserLoggedOutThroughFacebook
                                                            object:self];
    } else if (state == FBSessionStateClosedLoginFailed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kALNotificationUserLogginThroughFacebookFailed
                                                            object:self];
    }
}

- (void)signIn
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Open a session showing the user the login UI
    // You must ALWAYS ask for public_profile permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:self.permissions
                                       allowLoginUI:YES
                                  completionHandler: ^(FBSession *session, FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session state:state error:error];
                                  }
     ];
}

- (void)signOut
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        NSError *error;
        [self sessionStateChanged:FBSession.activeSession state:FBSession.activeSession.state error:error];
    }
}

- (void)handleDidBecomeActive
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [FBAppCall handleDidBecomeActive];
}

- (void)getInfo
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSLog(@"get info result: %@", result);
                self.userInfo = [self userInfoWithFBGraphObject:result];
                
                // if facebook user doesn't have an email stop sign in process and send out notification to handle
                // this event
                if (!self.userInfo) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kALNotificationFacebookUserHasNoEmail object:nil];
                    return;
                }
                
                [self getFriendsList];
            }
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
}

- (NSDictionary *)userInfoWithFBGraphObject:(FBGraphObject *)graphObject
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // check if user has an email with thier facebook info. If they do not return nil
    // and send out notification to let app handle this case
    if (!graphObject[@"email"]) {
        return nil;
    }
    
    NSMutableDictionary *info = [NSMutableDictionary new];
    for (id key in graphObject.allKeys) {
        info[key] = graphObject[key];
    }
    
    return info;
}

- (void)getFriendsList
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error) {
                                  NSLog(@"%@", error.description);
                              } else {
                                  self.friendsList = [self friendsListWithFBGraphObject:result];
                                  NSLog(@"friends list from fb query: %@", self.friendsList.description);
                                  
                                  __weak typeof (self)weakself = self;
                                  
                                  [self getPictureForUserId:self.userInfo[@"id"] onCompletion:^(UIImage *pic) {
                                      __strong typeof (weakself)strongSelf = weakself;
                                      self.imageData = UIImageJPEGRepresentation(pic, 1.0f);
                                      [strongSelf saveUser];
                                  }];
                              }
                          }];
}

- (NSArray *)friendsListWithFBGraphObject:(FBGraphObject *)graphObject
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSArray *graphArray = graphObject[@"data"];
    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *friendObject in graphArray) {
        NSDictionary *friend = @{@"name":friendObject[@"name"],
                                 @"id":friendObject[@"id"]
                                 };
        [list addObject:friend];
    }
    
    return list;
}

- (void)getPictureForUserId:(NSString *)userId onCompletion:(void(^)(UIImage *))doneFetchingBlock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];

    [request setTimeoutInterval:kALFaceBookManagerTimeOut];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                NSLog(@"response: %@", response);
                                                                
                                                                UIImage *responseImage = nil;
                                                                
                                                                if (error) {
                                                                    NSLog(@"Error downloading pic: %@", error.localizedDescription);
                                                                    responseImage = [UIImage imageNamed:@"userimage"];
                                                                } else {
                                                                    NSData *responseData = [NSData dataWithContentsOfURL:location];
                                                                    responseImage = [UIImage imageWithData:responseData];
                                                                }
                                                                
                                                                [ALProfilePicManager.manager saveProfilePic:responseImage forUserProfileId:userId];
                                                                if (doneFetchingBlock) {
                                                                    doneFetchingBlock(responseImage);
                                                                }
                                                            }];
    [downloadTask resume];
}

- (void)saveUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableArray *friends = [NSMutableArray new];
    for (NSDictionary *friendDict in self.friendsList) {
        NSMutableDictionary *alFriends = [NSMutableDictionary new];
        
        NSString *name = friendDict[@"name"];
        NSArray *names = [name componentsSeparatedByString:@" "];
        
        NSString *firstName = [names firstObject];
        [alFriends setObject:firstName forKey:kALFriendFirstName];
        
        if (names.count > 1) {
            NSString *lastName = [names lastObject];
            [alFriends setObject:lastName forKey:kALFriendLastName];
        }
        
        [alFriends setObject:friendDict[@"id"] forKey:kALFriendProfileId];
        [friends addObject:alFriends];
    }
    
    NSString *password = [NSString stringWithFormat:@"%@%@", self.userInfo[@"id"], self.userInfo[@"email"]];
    
    NSDictionary *user = @{kALUserProfileId:self.userInfo[@"id"],
                           kALUserFirstName:self.userInfo[@"first_name"],
                           kALUserLastName:self.userInfo[@"last_name"],
                           kALUserEmail:self.userInfo[@"email"],
                           kALUserProfileUrl:self.userInfo[@"link"],
                           kALUserPassword:password,
                           kALUserPic:self.imageData,
                           kALUserFriends:friends,
                           kALUserType:@"facebook"
                           };
    
    [[ALUserManager manager] saveUser:user saveToServer:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kALNotificationUserLoggedInThroughFacebookSuccessful
                                                        object:self];
}

@end
