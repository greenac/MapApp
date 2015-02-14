//
//  ALContact.h
//  Banter!
//
//  Created by Andre Green on 10/8/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALContact : NSObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, assign) NSUInteger idNumber;
@property (nonatomic, assign) BOOL isSelected;

- (id)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phoneNumber:(NSString *)phoneNumber;

- (NSString *)fullName;

@end
