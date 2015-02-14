//
//  ALComment+Methods.h
//  Banter!
//
//  Created by Andre Green on 11/29/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALComment.h"

#define kALCommentSceneId           @"scene_id"
#define kALCommentUserName          @"username"
#define kALCommentComment           @"comment"
#define kALCommentPicData           @"pic"
#define kALCommentFirstName         @"first_name"
#define kALCommentLastName          @"last_name"
#define kALCommentElapsedTime       @"elapsed_time"
#define kALCommentDateCreated       @"date_created"
#define kALCommentServerCommentId   @"comment_id"

@interface ALComment (Methods)

- (BOOL)equalsComment:(ALComment *)comment;
- (NSString *)fullName;
- (NSString *)elapsedTime;
- (NSDictionary *)asDictionary;

@end
