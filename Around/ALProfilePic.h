//
//  ALProfilePic.h
//  Banter!
//
//  Created by Andre Green on 12/2/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ALComment;

@interface ALProfilePic : NSManagedObject

@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSData * pic;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *comment;
@end

@interface ALProfilePic (CoreDataGeneratedAccessors)

- (void)addCommentObject:(ALComment *)value;
- (void)removeCommentObject:(ALComment *)value;
- (void)addComment:(NSSet *)values;
- (void)removeComment:(NSSet *)values;

@end
