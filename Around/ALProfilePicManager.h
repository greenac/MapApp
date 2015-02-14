//
//  ALProfilePicManager.h
//  Banter!
//
//  Created by Andre Green on 12/1/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALProfilePic.h"

@class ALProfilePicManager, ALEvent;

typedef NS_ENUM(NSUInteger, ALEventIconType) {
    ALEventIconTypeNone,
    ALEventIconTypeMapPin,
    ALEventIconTypePin,
    ALEventIconTypeDot,
    ALEventIconTypeFilter,
};

@protocol ALProfilePicDelegate <NSObject>

- (void)profilePicManager:(ALProfilePicManager *)picManager didSavePic:(ALProfilePic *)profilePic;

@end

@interface ALProfilePicManager : NSObject

@property (nonatomic, weak) id <ALProfilePicDelegate> delegate;
@property (nonatomic, assign) CGFloat scaleFactor;

+ (id)manager;
- (void)saveProfilePic:(UIImage *)profilePic forUser:(NSString *)userName;
//- (UIImage *)profilePicForUser:(NSString *)userName;
- (void)profilePicForUser:(NSString *)userName withCompletion:(void(^)(UIImage *))completion;
- (void)saveCurrentUsersPicToServerWithCallback:(void (^)(NSNumber *result))callback;
- (void)getPicsForUsernames:(NSSet *)usernames withCallBack:(void (^)(NSNumber *result))callback;
- (void)makeEventIconUrls;
- (void)iconForEvent:(ALEvent *)event iconType:(ALEventIconType)iconType withCompletion:(void(^)(UIImage *icon))completion;
- (UIImage *)iconForEvent:(ALEvent *)event iconType:(ALEventIconType)iconType;
- (UIImage *)iconForName:(NSString *)name iconType:(ALEventIconType)iconType isActive:(BOOL)isActive;
- (void)saveProfilePic:(UIImage *)profilePic forUserProfileId:(NSString *)profileId;

//- (void)getProfilePicFromServerForUsername:(NSString *)username picDictionary:(NSMutableDictionary *)picDictionary;
@end
