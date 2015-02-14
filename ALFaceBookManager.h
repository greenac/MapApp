//
//  ALFaceBookManager.h
//  Banter!
//
//  Created by Andre Green on 10/4/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ALFaceBookManager : NSObject

+ (id)manager;
- (void)signIn;
- (void)signOut;
- (void)setUp;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;
- (void)handleDidBecomeActive;
- (void)getInfo;
- (void)getPictureForUserId:(NSString *)userId onCompletion:(void(^)(UIImage *))doneFetchingBlock;

@end
