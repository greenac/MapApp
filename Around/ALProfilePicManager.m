//
//  ALProfilePicManager.m
//  Banter!
//
//  Created by Andre Green on 12/1/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALProfilePicManager.h"
#import "ALUrls.h"
#import "ALUserManager.h"
#import "ALUser.h"
#import "ALProfilePic.h"
#import "ALAppDelegate.h"
#import "ALMapManager.h"
#import "ALEvent.h"
#import "Responses.h"
#import "ALFaceBookManager.h"
#import "ALFriend.h"

#define kALProfilePicManagerTimeOut     30
#define kALProfilePicManagerEntity      @"ALProfilePic"
#define KALIconEventDir                 @"eventsIcons"
#define kALProfilePicDir                @"profilePics"
#define kALProfilePicExtension          @".jpg"


@interface ALProfilePicManager()

@property (nonatomic, strong) NSCache *iconCache;
@property (nonatomic, strong) NSCache *profilePicCache;
@property (nonatomic, strong) NSDictionary *eventIconUrls;
@property (nonatomic, strong) NSOperationQueue *profielPicQueue;

@end

@implementation ALProfilePicManager

+ (id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static ALProfilePicManager *picManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        picManager = [[self alloc] init];
    });
    
    return picManager;
}

- (id)init
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        _iconCache                  = [[NSCache alloc] init];
        _iconCache.countLimit       = 20;
        _profilePicCache            = [[NSCache alloc] init];
        _profilePicCache.countLimit = 20;
        _scaleFactor                = [self makeScaleFactor];
        _profielPicQueue            = [[NSOperationQueue alloc] init];
        _profielPicQueue.maxConcurrentOperationCount = 20;
    }
    
    return self;
}

- (void)saveProfilePic:(UIImage *)profilePic forUserProfileId:(NSString *)profileId
{
    ALFriend *friend = [ALUserManager.manager friendWithProfileId:profileId];
    if (friend && friend.email) {
        [self saveProfilePic:profilePic forUser:friend.email];
    }
}

- (void)saveProfilePic:(UIImage *)profilePic forUser:(NSString *)userName
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (profilePic && userName) {
        // save to disk
        NSString *savePath = [self profilePicPathForUserName:userName];
        NSData *picData = UIImageJPEGRepresentation(profilePic, 1.0);
        [picData writeToFile:savePath atomically:NO];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:savePath]];
        // cache image
        [self.profilePicCache setObject:profilePic forKey:userName];
        
    }
}

- (UIImage *)profilePicForUser:(NSString *)userName
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // check if image is in cache
    if ([self.profilePicCache objectForKey:userName]) {
        return [self.profilePicCache objectForKey:userName];
    }
    
    // check if image is on disk
    NSString *savePath = [self profilePicPathForUserName:userName];
    NSFileManager *fileManager = [NSFileManager new];
    
    if ([fileManager fileExistsAtPath:savePath]) {
        // pic is on disk. add to cache an return image
        NSData *picData = [fileManager contentsAtPath:savePath];
        UIImage *profilePic = [UIImage imageWithData:picData scale:self.scaleFactor];
        [self.iconCache setObject:profilePic forKey:userName];
        return profilePic;
    }
    
    // profile pic not on phone. return default icon, and try and fetch pic from server
    // TO-DO this should have a call back function to update view when server returns pic
    [self getProfilePicFromServerForUsername:userName withCompletion:nil];
    return [UIImage imageNamed:@"userImage"];
}

- (void)profilePicForUser:(NSString *)userName withCompletion:(void (^)(UIImage *))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    // check if image is in cache
    if ([self.profilePicCache objectForKey:userName] && completion) {
        completion([self.profilePicCache objectForKey:userName]);
        return;
    }
    
    // check if image is on disk
    NSString *savePath = [self profilePicPathForUserName:userName];
    NSFileManager *fileManager = [NSFileManager new];
    
    if ([fileManager fileExistsAtPath:savePath]) {
        // pic is on disk. add to cache an return image
        NSData *picData = [fileManager contentsAtPath:savePath];
        UIImage *profilePic = [UIImage imageWithData:picData scale:self.scaleFactor];
        [self.profilePicCache setObject:profilePic forKey:userName];
        if (completion) {
            completion(profilePic);
            return;
        }
    }
    
    // fetch from server
    [ALFaceBookManager.manager getPictureForUserId:userName onCompletion:completion];
    //[self getProfilePicFromServerForUsername:userName withCompletion:completion];
}

- (NSString *)profilePicPathForUserName:(NSString *)userName
{
    NSString *dirPath = [self cacheDirPathForDirectroy:kALProfilePicDir];
    NSString *savePath = [NSString stringWithFormat:@"%@%@%@", dirPath, userName, kALProfilePicExtension];
    return savePath;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    return success;
}

- (void)iconForEvent:(ALEvent *)event iconType:(ALEventIconType)iconType withCompletion:(void(^)(UIImage *icon))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSString *active = event.isOngoing ? @"Active" : @"NotActive";
    NSString *kind = [self nameForIconType:iconType];
    NSString *type = event.type;
    static NSString *ext = @".png";
    
    if (event.typeExt.intValue > 0) {
        type = [type stringByAppendingString:event.typeExt.stringValue];
    }
    
    NSString *iconName = [NSString stringWithFormat:@"%@%@%@%@%@", type, kind, active, [self imageScale], ext];
    
    [self getEventIcon:iconName url:nil withCompletion:completion];
}

- (UIImage *)iconForEvent:(ALEvent *)event iconType:(ALEventIconType)iconType
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSString *active = event.isOngoing ? @"Active" : @"NotActive";
    NSString *kind = [self nameForIconType:iconType];
    NSString *type = event.type;
    static NSString *ext = @".png";
    if (event.typeExt.intValue > 0) {
        type = [type stringByAppendingString:event.typeExt.stringValue];
    }
    
    NSString *iconName = [NSString stringWithFormat:@"%@%@%@%@%@", type, kind, active, [self imageScale], ext];
    
    UIImage *icon = [self getEventIcon:iconName];
    
    return icon;
}

- (UIImage *)iconForName:(NSString *)name iconType:(ALEventIconType)iconType isActive:(BOOL)isActive
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSString *active = isActive ? @"Active" : @"NotActive";
    NSString *kind = [self nameForIconType:iconType];
    static NSString *ext = @".png";
    
    NSString *iconName = [NSString stringWithFormat:@"%@%@%@%@%@", name, kind, active, [self imageScale], ext];
    
    UIImage *icon = [self getEventIcon:iconName];
    
    return icon;
}

- (NSString *)nameForIconType:(ALEventIconType)iconType
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSString *type;
    switch (iconType) {
        case ALEventIconTypeDot:
            type = @"Dot";
            break;
        case ALEventIconTypePin:
            type = @"Pin";
            break;
        case ALEventIconTypeMapPin:
            type = @"MapPin";
            break;
        case ALEventIconTypeFilter:
            type = @"Filter";
            break;
        case ALEventIconTypeNone:
            type = @"";
            break;
        default:
            break;
    }
    
    return type;
}

- (NSString *)imageScale
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSString *scale;
    UIScreen *screen = [UIScreen mainScreen];
    NSUInteger scaleFactor = (NSUInteger)self.scaleFactor;
    
    if ([screen respondsToSelector:@selector(scale)]) {
        scale = [NSString stringWithFormat:@"@%lux", (unsigned long)scaleFactor];
    } else {
        scale = @"";
    }
    
    return scale;
}

- (CGFloat)makeScaleFactor
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    UIScreen *screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)]) {
        return screen.scale;
    }
    
    return 1.0f;
}

- (void)makeEventIconUrls
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self getEventIconUrlsWithCompletion:^(NSDictionary *responseDict) {
            if (responseDict && responseDict[@"event_icon_urls"]) {
                self.eventIconUrls = responseDict[@"event_icon_urls"];
                for (NSArray *iconUrlArray in self.eventIconUrls.allValues) {
                    for (NSString *iconUrl in iconUrlArray) {
                        [self getEventIcon:nil url:iconUrl withCompletion:nil];
                    }
                }
            }
        }];
    });
}

- (NSString *)cacheDirPathForDirectroy:(NSString *)cacheDirectory
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDirPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, cacheDirectory];
    if (![fileManager fileExistsAtPath:cacheDirPath]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:cacheDirPath withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error) {
            NSLog(@"could not create dir: %@...failed with error: %@", cacheDirPath, error.localizedDescription);
            cacheDirPath = nil;
        }
    }
    
    if (cacheDirPath) {
        cacheDirPath = [cacheDirPath stringByAppendingString:@"/"];
    }
    
    return cacheDirPath;
}

- (UIImage *)getEventIcon:(NSString *)imageName
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    UIImage *icon = nil;
    // check if image is in cache
    if ([self.iconCache objectForKey:imageName]) {
        icon = [self.iconCache objectForKey:imageName];
    }
    
    // otherwise check if image is in main bundle
    NSString *dirPath = [self cacheDirPathForDirectroy:KALIconEventDir];
    icon = [UIImage imageNamed:imageName];
    
    if (icon) {
        [self.iconCache setObject:icon forKey:imageName];
    } else {
        NSFileManager *fileManager = [NSFileManager new];
        NSString *path = [dirPath stringByAppendingString:imageName];
        
        if ([fileManager fileExistsAtPath:path]) {
            // pic is on disk. add to cache an return image
            NSData *picData = [fileManager contentsAtPath:path];
            icon = [UIImage imageWithData:picData scale:self.scaleFactor];
            [self.iconCache setObject:icon forKey:imageName];
        }
    }
    
    return icon;
}

- (void)getEventIcon:(NSString *)imageName url:(NSString *)url withCompletion:(void(^)(UIImage *icon))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (!imageName) {
        imageName = [self extractIconNameFromUrl:url];
    }
    
    UIImage *icon;
    // check if image is in cache
    if ([self.iconCache objectForKey:imageName]) {
        icon = [self.iconCache objectForKey:imageName];
        [self executeIconBlock:completion withParameter:icon];
        return;
    }
    
    // otherwise check if image is on disk
    NSString *dirPath = [self cacheDirPathForDirectroy:KALIconEventDir];
    icon = [UIImage imageNamed:imageName];
    
    if (icon) {
        [self.iconCache setObject:icon forKey:imageName];
        [self executeIconBlock:completion withParameter:icon];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager new];
    NSString *path = [dirPath stringByAppendingString:imageName];
    
    if ([fileManager fileExistsAtPath:path]) {
        // pic is on disk. add to cache an return image
        NSData *picData = [fileManager contentsAtPath:path];
        icon = [UIImage imageWithData:picData scale:self.scaleFactor];
        if (icon) {
            [self.iconCache setObject:icon forKey:imageName];
            [self executeIconBlock:completion withParameter:icon];
            return;
        } else {
            NSLog(@"Error reading event icon from disk for: %@", imageName);
            [self executeIconBlock:completion withParameter:nil];
        }
    }
    
    // image does not exist on device...get it from web
    [self getEventIconNamed:imageName url:url withCompletion:completion];
}

- (void)executeIconBlock:(void(^)(UIImage *icon))completion withParameter:(id)parameter
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (completion && (!parameter || [parameter isMemberOfClass:[UIImage class]])) {
        completion(parameter);
    }
}

- (NSString *)extractIconNameFromUrl:(NSString *)url
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSArray *urlParts = [url componentsSeparatedByString:@"/"];
    return [urlParts lastObject];
}

- (void)saveEventIcon:(NSData *)iconData withName:(NSString *)iconName onCompletion:(void(^)(UIImage *icon))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    UIImage *icon = [UIImage imageWithData:iconData];
    
    [self.iconCache setObject:icon forKey:iconName];
    
    NSString *dirPath = [self cacheDirPathForDirectroy:KALIconEventDir];
    if (dirPath) {
        NSString *path = [dirPath stringByAppendingString:iconName];
        [iconData writeToFile:path atomically:NO];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
        
        [self executeIconBlock:completion withParameter:icon];
    } else {
        [self executeIconBlock:completion withParameter:nil];
    }
}

- (void)saveCurrentUsersPicToServerWithCallback:(void (^)(NSNumber *result))callback
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, POST_PROFILE_PIC_URL];
    
    ALUser *currentUser = [[ALUserManager manager] currentUser];
    UIImage *pic = [self profilePicForUser:currentUser.email];
    NSData *picData = UIImageJPEGRepresentation(pic, 1.0f);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request setValue:currentUser.email forHTTPHeaderField:@"username"];
    [request setHTTPBody:picData];
    [request setTimeoutInterval:kALProfilePicManagerTimeOut];
    
    NSLog(@"request headers for profile pic: %@", request.allHTTPHeaderFields);
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:picData
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSLog(@"response url %@, encoding %@", response.URL, response.textEncodingName);
                                                          NSNumber *responseNumber = @(ALUserManagerPicSaveFailed);
                                                          if (error) {
                                                              NSLog(@"error in user manager verify user callback: %@", error.localizedDescription);
                                                          } else {
                                                              NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                              if (error) {
                                                                  NSLog(@"Error: %@", error.localizedDescription);
                                                              } else {
                                                                  responseNumber = responseDict[@"response"];
                                                              }
                                                          }
                                                          
                                                          if (callback) {
                                                              callback(responseNumber);
                                                          }
                                                      }];
    [uploadTask resume];
}

- (void)getPicsForUsernames:(NSSet *)usernames withCallBack:(void (^)(NSNumber *))callback
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    for (NSString *username in usernames.allObjects) {
        [self getProfilePicFromServerForUsername:username withCompletion:nil];
    }
}

- (void)getProfilePicFromServerForUsername:(NSString *)username withCompletion:(void(^)(UIImage *))completion {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, GET_PROFILE_PIC_URL];
    
    NSDictionary *usernameDict = @{@"username":username};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:usernameDict options:0 error:&error];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"applcations/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:kALProfilePicManagerTimeOut];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:jsonData
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                                                          NSLog(@"response url %@, encoding %@, headers: %@", response.URL, response.textEncodingName, urlResponse.allHeaderFields);
                                                          if (error) {
                                                              NSLog(@"error in user manager verify user callback: %@", error.localizedDescription);
                                                          } else {
                                                              UIImage *image = [UIImage imageWithData:data];
                                                              [self saveProfilePic:image forUser:username];
                                                              completion(image);
                                                          }
                                                      }];
    [uploadTask resume];
}

- (void)getEventIconUrlsWithCompletion:(void(^)(NSDictionary *responseDict))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, EVENT_ICON_URLS];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"applcations/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:kALProfilePicManagerTimeOut];
    
    NSURLSessionDataTask *downloadTask= [session dataTaskWithRequest:request
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                                                          NSLog(@"response url %@, encoding %@, headers: %@", response.URL, response.textEncodingName, urlResponse.allHeaderFields);
                                                          if (error) {
                                                              NSLog(@"error in user manager verify user callback: %@", error.localizedDescription);
                                                              completion(nil);
                                                          } else {
                                                              NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                              if (error) {
                                                                  NSLog(@"Error getting event icon urls. Failed with error: %@", error.localizedDescription);
                                                                  completion(nil);
                                                              } else {
                                                                  NSNumber *responseNumber = responseDict[@"response"];
                                                                  if (responseNumber.intValue == KALResponseSuccess) {
                                                                      completion(responseDict);
                                                                  } else {
                                                                      completion(nil);
                                                                  }
                                                              }
                                                          }
                                                      }];
    [downloadTask resume];
}

- (void)getEventIconNamed:(NSString *)iconName url:(NSString *)url withCompletion:(void(^)(UIImage *icon))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:kALProfilePicManagerTimeOut];
    NSLog(@"making requst for icon: %@", iconName);
    NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                                                        NSLog(@"response url for icon: %@ %@, encoding %@, headers: %@", iconName, response.URL, response.textEncodingName, urlResponse.allHeaderFields);
                                                        if (error) {
                                                            NSLog(@"error in user manager verify user callback: %@", error.localizedDescription);
                                                        } else {
                                                            NSLog(@"recieved data for %@", iconName);
                                                            [self saveEventIcon:data withName:iconName onCompletion:completion];
                                                        }
    }];

    [downloadTask resume];
}
@end
