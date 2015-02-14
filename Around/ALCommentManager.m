//
//  ALCommentManager.m
//  Banter!
//
//  Created by Andre Green on 11/27/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALCommentManager.h"
#import "ALComment+Methods.h"
#import "ALAppDelegate.h"
#import "ALUserManager.h"
#import "ALUser.h"
#import "ALDateFormatter.h"
#import "ALEvent.h"
#import "ALScene.h"
#import "ALUrls.h"

#define kALCommentManagerEntityComment  @"ALComment"
#define kALCommentManagerTimeOut        30

@interface ALCommentManager()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation ALCommentManager

+ (id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static ALCommentManager *commentManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        commentManager = [[self alloc] init];
    });
    
    return commentManager;
}

- (id)init
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        _context = ((ALAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
    return self;
}

//- (void)saveProfilePic:(ALProfilePic *)profilePic
//{
//    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kALCommentManagerEntityComment
//                                                         inManagedObjectContext:self.context];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username LIKE %@", profilePic.username];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:entityDescription];
//    [request setPredicate:predicate];
//    
//    NSError *error;
//    NSArray *comments = [self.context executeFetchRequest:request error:&error];
//    if (comments) {
//        if (comments.count > 0) {
//            ALComment *comment = comments[0];
//            comment.profilePic = profilePic;
//            
//            NSError *error;
//            if (![self.context save:&error]) {
//                NSLog(@"Couldn't save profile pic for comment: %@", [error localizedDescription]);
//            } else {
//                if ([self.delegate respondsToSelector:@selector(commentManager:updatedPicForComment:)]) {
//                    [self.delegate commentManager:self updatedPicForComment:comment];
//                }
//            }
//        }
//    }
//}

- (void)saveAllCommentsFromServer:(NSDictionary *)comments callback:(void(^)(NSDictionary * currentComments))callbackBlock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // comments organized by sceneId for key with array of comments as value
    for (NSArray *commentsArray in comments.allValues) {
        for (NSDictionary *commentDict in commentsArray) {
            [self saveCommentToDBFromDictionary:commentDict];
        }
    }
    
    if (callbackBlock) {
        NSDictionary *commentObjects = [self getCommentsFromDbWithSceneIds:comments.allKeys];
        NSMutableArray *a = [NSMutableArray new];
        for (NSNumber *key in commentObjects.allKeys) {
            NSArray *commentsArray = commentObjects[key];
            for (ALComment *comment in commentsArray) {
                 [a addObject:comment.asDictionary];
            }
        }
        
        NSLog(@"%@", a.description);
        callbackBlock(commentObjects);
    }
}

- (void)saveCommentForCurrentUserToDb:(NSString *)comment forScene:(ALScene *)scene
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ALUser *currentUser = [[ALUserManager manager] currentUser];
    NSDictionary *commentDict = @{kALCommentSceneId:scene.sceneId,
                                  kALCommentUserName:currentUser.email,
                                  kALCommentFirstName:currentUser.firstName,
                                  kALCommentLastName:currentUser.lastName,
                                  kALCommentComment:comment
                                  };
    
    [self saveCommentToDBFromDictionary:commentDict];
    
}

- (void)saveCommentToDBFromDictionary:(NSDictionary *)dictionary
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // user is making comment. save comment and send data to server
    ALComment *comment = [self getCommentFromDBWithCommentDict:dictionary];
    if (!comment) {
        // no comment saved to phone's database -- save comment
        comment = [NSEntityDescription insertNewObjectForEntityForName:kALCommentManagerEntityComment
                                                inManagedObjectContext:self.context];
    }
    
    [self setCommentProperties:comment withDictionary:dictionary];

    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Couldn't save comment: %@", [error localizedDescription]);
    } else {
        // get comment profile pic
        ALProfilePicManager *picManager = [ALProfilePicManager manager];
        [picManager profilePicForUser:comment.username withCompletion:nil];
    }
}

- (BOOL)commentExists:(NSDictionary *)commentDict
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    if ([self getCommentFromDBWithCommentDict:commentDict]) {
        return YES;
    }
    return NO;
}

- (NSPredicate *)predicateForCommentLookUp:(NSDictionary *)commentDict
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSPredicate *usernamePredicate = [NSPredicate predicateWithFormat:@"username LIKE %@", commentDict[kALCommentUserName]];
    NSPredicate *scenePredicate = [NSPredicate predicateWithFormat:@"sceneId == %@", commentDict[kALCommentSceneId]];
    NSPredicate *commentPredicate = [NSPredicate predicateWithFormat:@"comment LIKE %@", commentDict[kALCommentComment]];
    
    NSArray *predicates = @[usernamePredicate, scenePredicate, commentPredicate];
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];

    return predicate;
}

- (NSString *)predicateStringForCommentLookUpBySceneId:(NSNumber *)sceneId
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [NSString stringWithFormat:@"sceneId == %@", sceneId];
}

- (void)setCommentProperties:(ALComment *)comment withDictionary:(NSDictionary *)commentDict
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    comment.firstName = commentDict[kALCommentFirstName];
    comment.lastName = commentDict[kALCommentLastName];
    comment.username = commentDict[kALCommentUserName];
    comment.sceneId = commentDict[kALCommentSceneId];
    comment.comment = commentDict[kALCommentComment];

    if (commentDict[kALCommentDateCreated]) {
        [ALDateFormatter.formatter setZoneToUTC];
        comment.dateCreated = [ALDateFormatter.formatter dateFromString:commentDict[kALCommentDateCreated]];
        [ALDateFormatter.formatter setZoneToLocal];
    }
    
    if (commentDict[kALCommentServerCommentId]) {
        comment.commentId = commentDict[kALCommentServerCommentId];
    } else {
        // set comment id to -1 if the comment is created on client and sent to server
        // the -1 will be flag to update this comment's date from server's date created
        // when callback is recieved
        comment.commentId = @(-1);
    }
    
//    ALProfilePic *profilePic = [ALProfilePicManager.manager profilePicForUser:comment.username];
//    if (profilePic) {
//        comment.profilePic = profilePic;
//    }
    
    NSLog(@"comment: %@", comment.asDictionary);
}

- (NSDictionary *)getCommentsFromDbWithSceneIds:(NSArray *)sceneIds
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableDictionary *comments = [NSMutableDictionary new];
    for (NSNumber *scenedId in sceneIds) {
        NSArray *commentsForScene = [self getCommentsFromDbWithSingleSceneId:scenedId];

        if (commentsForScene) {
            NSMutableArray *commentsWithDates = [NSMutableArray new];
            NSMutableArray *commentsSorted = [NSMutableArray new];
            for (ALComment *comment in commentsForScene) {
                if (comment.dateCreated) {
                    [commentsWithDates addObject:comment];
                } else {
                    [commentsSorted addObject:comment];
                }
            }
            
            NSArray *sortedComments = [commentsWithDates sortedArrayUsingComparator:^NSComparisonResult(ALComment *obj1, ALComment *obj2) {
                return [obj1.dateCreated compare:obj2.dateCreated] == NSOrderedAscending;
            }];
            
            [commentsSorted addObjectsFromArray:sortedComments];
            comments[scenedId] = commentsSorted;
        }
    }
    
    NSMutableArray *testComments = [NSMutableArray new];
    for (NSNumber *num in comments) {
        NSArray *commentsArray = comments[num];
        for (ALComment *testcomment in commentsArray) {
            [testComments addObject:testcomment.asDictionary];
        }
    }
    
    NSLog(@"test comments: %@", testComments.description);
    
    return comments;
}

- (NSArray *)getCommentsFromDbWithSingleSceneId:(NSNumber *)sceneId
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kALCommentManagerEntityComment
                                                         inManagedObjectContext:self.context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[self predicateStringForCommentLookUpBySceneId:sceneId]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *comments = [self.context executeFetchRequest:request error:&error];
    
    return comments;
}

- (ALComment *)getCommentFromDBWithCommentDict:(NSDictionary *)commentDict
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kALCommentManagerEntityComment
                                                         inManagedObjectContext:self.context];
    
    NSPredicate *predicate = [self predicateForCommentLookUp:commentDict];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *comments = [self.context executeFetchRequest:request error:&error];
    
    if (comments.count != 0) {
        return comments[0];
    }
    
    return nil;
}

- (NSDictionary *)convertViableKeysToNumbers:(NSDictionary *)dictFromJson
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSMutableDictionary *returnDict = [dictFromJson mutableCopy];
    for (NSString *key in dictFromJson.allKeys) {
        NSNumber *keyNumber = [formatter numberFromString:key];
        if (keyNumber) {
            [returnDict removeObjectForKey:key];
            [returnDict setObject:dictFromJson[key] forKey:keyNumber];
        }
    }
    
    return returnDict;
}

- (void)getCommentsForEvents:(NSArray *)events withCallBack:(void (^)(NSDictionary *comments))callBackBlock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSMutableSet *sceneIds = [NSMutableSet new];
    
    for (ALEvent *event in events) {
        [sceneIds addObject:event.scene.sceneId];
    }
    
    NSDictionary *sceneDict = @{@"scene_ids":sceneIds.allObjects};
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sceneDict options:0 error:&error];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, COMMENTS_FOR_SCENES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"applcations/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:kALCommentManagerTimeOut];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:jsonData
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSLog(@"response url %@, encoding %@", response.URL, response.textEncodingName);
                                                          if (error) {
                                                              NSLog(@"error in user manager verify user callback: %@", error.localizedDescription);
                                                          } else {
                                                              NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                              if (error) {
                                                                  NSLog(@"Error: %@", error.localizedDescription);
                                                              } else {
                                                                  NSDictionary *commentsDict = responseDict[@"comments"];
                                                                  [self saveAllCommentsFromServer:[self convertViableKeysToNumbers:commentsDict] callback:callBackBlock];
                                                              }
                                                          }
                                                      }];
    
    [uploadTask resume];
}

- (void)addCommentForScene:(ALScene *)scene comment:(NSString *)comment withCallBack:(void (^)(BOOL success))callBackBlock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    ALUser *user = [[ALUserManager manager] currentUser];
    
    NSDictionary *commentDict = @{@"scene_id":scene.sceneId,
                                  @"email":user.email,
                                  @"comment":comment
                                  };
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:commentDict options:0 error:&error];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, SAVE_COMMENT];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"applcations/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:kALCommentManagerTimeOut];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:jsonData
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSLog(@"response url %@, encoding %@", response.URL, response.textEncodingName);
                                                          if (error) {
                                                              NSLog(@"error in user manager verify user callback: %@", error.localizedDescription);
                                                          } else {
                                                              NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                              if (error) {
                                                                  NSLog(@"Error: %@", error.localizedDescription);
                                                              } else {
                                                                  NSNumber *responseNumber = responseDict[@"response"];
                                                                  NSLog(@"save coment returned: %@", responseNumber);
                                                                  BOOL saveSuccessful = (responseNumber.integerValue == 614) ? YES:NO;
                                                                  
                                                                  if (callBackBlock) {
                                                                      callBackBlock(saveSuccessful);
                                                                  }
                                                                  
                                                                  ALEvent *currentEvent = [[ALEvent alloc] init];
                                                                  currentEvent.scene = scene;
                                                                  [self getCommentsForEvents:@[currentEvent] withCallBack:nil];
                                                              }
                                                          }
                                                      }];
    
    [uploadTask resume];
}

#pragma mark - profile pic delegate methods
- (void)profilePicManager:(ALProfilePicManager *)picManager didSavePic:(ALProfilePic *)profilePic
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    //[self saveProfilePic:profilePic];
}
@end
