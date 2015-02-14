//
//  ALComment.h
//  Banter!
//
//  Created by Andre Green on 1/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ALComment : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * commentId;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * sceneId;
@property (nonatomic, retain) NSString * username;

@end
