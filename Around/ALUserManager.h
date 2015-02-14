//
//  ALUserManager.h
//  Banter!
//
//  Created by Andre Green on 10/4/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALUser, ALFriend;

typedef NS_ENUM(NSUInteger, ALUserManagerResponse) {
    ALUserManagerResponseDoesNotExist = 609,
    ALUserManagerResponseExists = 610,
    ALUserManagerResponseExistsWrongPassword = 611,
    ALUserManagerResponseCreationSuccessful = 612,
    ALUserManagerResponseConnectionFailed = 613,
    ALUserManagerPicSaveSuccesful = 800,
    ALUserManagerPicSaveFailed = 801,
    ALUserManagerNoUserForPicData = 802,
};


@interface ALUserManager : NSObject

+ (id)manager;

- (void)saveUser:(NSDictionary *)userDictRepresentation saveToServer:(BOOL)saveToServer;
- (void)saveCurrentUser;
- (void)verifyUserWithEmail:(NSString *)email andPassword:(NSString *)password completion:(void(^)(NSNumber *response))completion;
- (BOOL)isUserSignedIn;
- (BOOL)hasUserCompletedTutorial;
- (void)setUserSignedIn:(BOOL)isSignedIn;
- (void)setUserCompletedTutorial:(BOOL)hasCompleted;
- (void)saveCurrentUserToServerWithCallBack:(void (^)(NSNumber *result))callback;
- (ALUser *)checkUser;
- (ALUser *)currentUser;
- (ALFriend *)friendWithProfileId:(NSString *)profileId;

@end
