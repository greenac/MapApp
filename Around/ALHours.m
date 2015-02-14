//
//  ALHours.m
//  Around
//
//  Created by Andre Green on 9/3/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALHours.h"


#define kALHoursDayNameMonday    @"monday"
#define kALHoursDayNameTuesday   @"tuesday"
#define kALHoursDayNameWednesday @"wednesday"
#define kALHoursDayNameThursday  @"thursday"
#define kALHoursDayNameFriday    @"friday"
#define kALHoursDayNameSaturday  @"saturday"
#define kALHoursDayNameSunday    @"sunday"

@implementation ALHours

-(id)initWithDictionary:(NSDictionary *)hoursDict
{
    self = [super init];
    if (self) {
        _monday     = hoursDict[kALHoursDayNameMonday];
        _tuesday    = hoursDict[kALHoursDayNameTuesday];
        _wednesday  = hoursDict[kALHoursDayNameWednesday];
        _thursday   = hoursDict[kALHoursDayNameThursday];
        _friday     = hoursDict[kALHoursDayNameFriday];
        _saturday   = hoursDict[kALHoursDayNameSaturday];
        _sunday     = hoursDict[kALHoursDayNameSunday];
    }
    
    return self;
}

- (NSString*)hoursForCurrentDay
{
    NSInteger currentDay = [self currentDayNumber];
    NSString *hours;
    
    switch (currentDay) {
        case 1:
            hours = self.sunday;
            break;
        case 2:
            hours = self.monday;
            break;
        case 3:
            hours = self.tuesday;
            break;
        case 4:
            hours = self.wednesday;
            break;
        case 5:
            hours = self.thursday;
            break;
        case 6:
            hours = self.friday;
            break;
        case 7:
            hours = self.saturday;
            break;
        default:
            break;
    }
    
    NSArray *comps = [hours componentsSeparatedByString:@","];
    NSMutableString *formattedHours = [NSMutableString new];
    for (NSString *comp in comps) {
        [formattedHours appendString:[NSString stringWithFormat:@"%@ ", comp]];
    }
    
    return formattedHours;
}

- (NSInteger)currentDayNumber
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    return [comps weekday];
    
}
@end
