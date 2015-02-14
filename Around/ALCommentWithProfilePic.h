//
//  ALCommentWithProfilePic.h
//  Banter!
//
//  Created by Andre Green on 12/2/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALComment.h"
#import "ALProfilePic.h"

@interface ALCommentWithProfilePic : NSObject

@property (strong) ALComment *comment;
@property (strong) ALProfilePic *profilePic;

@end
