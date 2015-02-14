//
//  ALMapAnnotation.m
//  Around
//
//  Created by Andre Green on 8/23/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALMapAnnotation.h"
#import "ALAddress.h"
#import "ALHours.h"
#import "ALEvent.h"
#import "ALScene.h"
#import "ALProfilePicManager.h"

@interface ALMapAnnotation()

@end

@implementation ALMapAnnotation

@synthesize title = _title;
@synthesize coordinate = _coordinate;
@synthesize event = _event;
@synthesize selected = _selected;

- (id)initWithEvent:(ALEvent *)event
{
    self = [super init];
    if (self) {
        _title          = event.scene.name;
        _coordinate     = [event.address location];
        _event          = event;
        _selected       = NO;
    }
    return self;
}


-(MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:kALAnnotationReuseIdenifier];
    annotationView.enabled = YES;
    annotationView.canShowCallout = NO;
    annotationView.image = [self annotationImage];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (UIImage *)annotationImage
{
    ALEventIconType iconType = self.selected ? ALEventIconTypeMapPin : ALEventIconTypeDot;;
    UIImage *image = [ALProfilePicManager.manager iconForEvent:self.event iconType:iconType];
    return image;
}

- (NSString*)identifier
{
    NSString *iden = [NSString stringWithFormat:@"%@%@%f%f", self.title, self.event.type, self.coordinate.latitude, self.coordinate.longitude];
    return iden;
}

@end
