//
//  ALContact.m
//  Banter!
//
//  Created by Andre Green on 10/8/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALContact.h"

@implementation ALContact

- (id)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self) {
        _firstName      = firstName;
        _lastName       = lastName;
        _email          = email;
        _phoneNumber    = phoneNumber;
        _idNumber       = 0;
        _isSelected     = NO;
    }
    
    return self;
}

- (NSString *)fullName
{
    NSString *name;
    if (self.firstName && self.lastName) {
        name = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    } else if (self.firstName) {
        name = [NSString stringWithFormat:@"%@", self.firstName];
    }
    
    return name;
}

@end
