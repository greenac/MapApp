//
//  ALMapAnnotation.h
//  Around
//
//  Created by Andre Green on 8/23/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class ALAddress, ALHours, ALEvent;

#define kALAnnotationReuseIdenifier     @"annotationReuseIdentifer"

@interface ALMapAnnotation : NSObject <MKAnnotation>

@property(nonatomic, copy)NSString *title;
@property(nonatomic, readonly)CLLocationCoordinate2D coordinate;
@property(nonatomic, strong)ALEvent *event;
@property(nonatomic, assign)BOOL selected;

- (id)initWithEvent:(ALEvent*)event;
- (MKAnnotationView*)annotationView;
- (NSString*)identifier;
- (UIImage *)annotationImage;

@end
