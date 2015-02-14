//
//  ALCommentManager.h
//  Banter!
//
//  Created by Andre Green on 11/27/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALProfilePicManager.h"

@class ALScene, ALCommentManager;

@protocol ALCommentManagerDelegate <NSObject>

- (void)commentManager:(ALCommentManager *)commentManager updatedPicForComment:(ALComment *)comment;

@end

@interface ALCommentManager : NSObject <ALProfilePicDelegate>

@property (nonatomic, weak) id <ALCommentManagerDelegate> delegate;

+ (id)manager;

- (void)getCommentsForEvents:(NSArray *)events withCallBack:(void (^)(NSDictionary * comments))callBackBlock;
- (void)addCommentForScene:(ALScene *)scene comment:(NSString *)comment withCallBack:(void(^)(BOOL success))callBackBlock;
- (void)saveCommentForCurrentUserToDb:(NSString *)comment forScene:(ALScene *)scene;
- (NSDictionary *)getCommentsFromDbWithSceneIds:(NSArray *)sceneIds;

@end
