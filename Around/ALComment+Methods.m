//
//  ALComment+Methods.m
//  Banter!
//
//  Created by Andre Green on 11/29/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALComment+Methods.h"
#import "ALDateFormatter.h"
#import "ALProfilePicManager.h"

@implementation ALComment (Methods)

- (BOOL)equalsComment:(ALComment *)comment
{
    if (self.sceneId != comment.sceneId) {
        return NO;
    } else if (![self.username isEqualToString:comment.username]) {
        return NO;
    } else if (![self.comment isEqualToString:comment.comment]) {
        return NO;
    } else if([self.dateCreated compare:comment.dateCreated] != NSOrderedSame) {
        return NO;
    } else {
        return YES;
    }
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)elapsedTime
{
    NSDateComponents *dateComps = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute)
                                                                  fromDate:self.dateCreated
                                                                    toDate:[NSDate date]
                                                                   options:0];
    NSString *dateString;
    if (dateComps.day > 365) {
        dateString = [NSString stringWithFormat:@"%ld yrs ago", dateComps.day/365];
    } else if (dateComps.day > 30) {
        dateString = [NSString stringWithFormat:@"%ld months ago", dateComps.day/30];
    } else if (dateComps.day > 0) {
        dateString = [NSString stringWithFormat:@"%ld days ago", dateComps.day];
    } else if (dateComps.hour > 0) {
        dateString = [NSString stringWithFormat:@"%ld hrs ago", dateComps.hour];
    } else if (dateComps.minute > 0) {
        dateString = [NSString stringWithFormat:@"%ld mins ago", dateComps.minute];
    } else {
        dateString = @"now";
    }
    
    return dateString;
}

- (NSDictionary *)asDictionary
{
    NSDictionary *dictionary = @{kALCommentSceneId:[self safeValue:self.sceneId],
                                 kALCommentUserName:[self safeValue:self.username],
                                 kALCommentComment:[self safeValue:self.comment],
                                 kALCommentFirstName:[self safeValue:self.firstName],
                                 kALCommentLastName:[self safeValue:self.lastName],
                                 kALCommentElapsedTime:[self safeValue:self.elapsedTime],
                                 kALCommentServerCommentId:[self safeValue:self.commentId],
                                 kALCommentDateCreated:[self safeValue:[ALDateFormatter.formatter stringFromDate:self.dateCreated]],
                                 kALCommentPicData:[self safeValue:[self imageForCommentor:self.username]]
                                 };
    return dictionary;
}

- (id)safeValue:(id)value
{
    if (value) {
        return value;
    }
    
    return [NSNull null];
}

- (UIImage *)imageForCommentor:(NSString *)commentorName
{
//    UIImage *pic = [ALProfilePicManager.manager profilePicForUser:commentorName withCompletion:^(UIImage *) {
//        
//    }
//    return pic;
    return nil;
}
@end
