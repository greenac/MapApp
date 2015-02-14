//
//  ALFilterViewController.m
//  Banter!
//
//  Created by Andre Green on 1/15/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "ALFilterViewController.h"
#import "ALMapManager.h"
#import "ALProfilePicManager.h"


#define kALFilterVCActive       @"Active"
#define kALFilterVCNotActive    @"NotActive"


@interface ALFilterViewController ()

@property (nonatomic, strong) NSMutableDictionary *buttons;
@property (nonatomic, assign) CGFloat xSpacer;

@end

@implementation ALFilterViewController

- (void)viewDidLoad
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.view.layer.masksToBounds = NO;
    self.view.layer.cornerRadius = 3;
    self.view.layer.shadowOffset = CGSizeMake(0, 5);
    self.view.layer.shadowRadius = 3;
    self.view.layer.shadowOpacity = 0.75;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];
    [self setUpViews];
}

- (NSMutableDictionary *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableDictionary new];
    }
    return _buttons;
}

- (void)setUpViews
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSArray *filterOrder = [ALMapManager.manager eventFilterOrder];
    UIFont *labelFont = [UIFont systemFontOfSize:10.0f];
    UIColor *grey = [UIColor colorWithWhite:0.6f alpha:1.0f];
    
    // handle all traditional filter options
    UIImage *imageForXSpacer = [ALProfilePicManager.manager iconForName:filterOrder[0][0]
                                                               iconType:ALEventIconTypeFilter
                                                               isActive:YES];
    self.xSpacer = 0.5f*(self.view.bounds.size.width - kALFilterVCMaxColumns*imageForXSpacer.size.width) - kALFilterVCXPadding;
    CGFloat yPos = kALFilterVCYPadding;
    CGFloat xPos = kALFilterVCXPadding;
    CGFloat maxLabelWidth = self.view.bounds.size.width/3.0f;
    NSUInteger buttonCounter = 0;
    
    for (NSUInteger i=0; i < filterOrder.count-1; i++) {
        NSArray *filterArray = filterOrder[i];
        NSUInteger buttonsOnLine = 0;
        for (NSUInteger j=0; j < filterArray.count; j++) {
            NSString *filterName = filterArray[j];
            UIButton *button = [self filterButtonWithName:filterName];
            
            if (j % kALFilterVCMaxColumns == 0) {
                buttonsOnLine = [self numberOfButtonsOnLineForButtonAtIndex:buttonCounter
                                                         maxNumberOfButtons:filterArray.count];
            }
            
            button.frame = [self buttonFrameForButton:button
                                              atIndex:buttonCounter
                                        buttonsOnLine:buttonsOnLine
                                      andTotalButtons:filterArray.count
                                        withYPosition:yPos];
            button.tag = buttonCounter;
            [self.view addSubview:button];
            [self.buttons setObject:button forKey:filterName];
            
            // add event name label
            NSString *eventName = [self parseCamelCaseString:filterName];
            CGSize maxSize = CGSizeMake(maxLabelWidth, 20.0f);
            CGRect nameLabelRect = [eventName boundingRectWithSize:maxSize
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:labelFont}
                                                           context:nil];
            
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
            eventLabel.frame = CGRectMake(button.center.x - .5*eventLabel.frame.size.width,
                                          CGRectGetMaxY(button.frame) + 5.0f,
                                          eventLabel.frame.size.width,
                                          eventLabel.frame.size.height);
            eventLabel.font = labelFont;
            eventLabel.text = eventName;
            eventLabel.textColor = grey;
            eventLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:eventLabel];
            
            if (buttonCounter == kALFilterVCMaxColumns - 1) {
                // hit right edge of view. start a new row
                xPos = kALFilterVCXPadding;
                yPos += button.frame.size.height + 1.6f*kALFilterVCYPadding;
            } else {
                xPos += button.frame.size.width + self.xSpacer;
            }
            
            buttonCounter++;
        }
    }
    
    
    // place occupancy days available label
    UILabel *occupancyDaysLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                            self.view.bounds.size.height - 25.0f,
                                                                            self.view.bounds.size.width,
                                                                            25.0f)];
    occupancyDaysLabel.text = NSLocalizedString(@"Available on Fridays and Saturdays", nil);
    occupancyDaysLabel.font = [UIFont systemFontOfSize:10.0f];
    occupancyDaysLabel.textColor = grey;
    occupancyDaysLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:occupancyDaysLabel];
    
    // place arrow view
    UIImage *arrowImage = [UIImage imageNamed:@"filter_arrow"];
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowImage];
    arrowView.frame = CGRectMake(.5*(self.view.bounds.size.width - arrowView.bounds.size.width),
                                 occupancyDaysLabel.frame.origin.y- 1.1*arrowView.bounds.size.height,
                                 arrowView.bounds.size.width,
                                 arrowView.bounds.size.height);
    [self.view addSubview:arrowView];
    
    CGFloat labelWidth = 0.5f*(self.view.bounds.size.width - arrowView.frame.origin.x);
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(arrowView.frame.origin.x,
                                                                    occupancyDaysLabel.frame.origin.y - 5.0f,
                                                                    labelWidth,
                                                                    15.0f)];
    emptyLabel.font = labelFont;
    emptyLabel.textAlignment = NSTextAlignmentLeft;
    emptyLabel.text = NSLocalizedString(@"Empty", nil);
    emptyLabel.textColor = grey;
    [self.view addSubview:emptyLabel];
    
    UILabel *packedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - arrowView.frame.origin.x - labelWidth,
                                                                     emptyLabel.frame.origin.y,
                                                                     labelWidth,
                                                                     emptyLabel.bounds.size.height)];
    packedLabel.font = labelFont;
    packedLabel.textAlignment = NSTextAlignmentRight;
    packedLabel.text = NSLocalizedString(@"Packed", nil);
    packedLabel.textColor = grey;
    [self.view addSubview:packedLabel];
    
    arrowView.frame = CGRectMake(arrowView.frame.origin.x,
                                 emptyLabel.frame.origin.y - 6.0f,
                                 arrowView.frame.size.width,
                                 arrowView.frame.size.height);
    
    // place occupancy filters.
    NSArray *occupancyArray = [filterOrder lastObject];
    imageForXSpacer = [ALProfilePicManager.manager iconForName:occupancyArray[0]
                                                      iconType:ALEventIconTypeDot
                                                      isActive:YES];
    self.xSpacer = (self.view.bounds.size.width - 2*arrowView.frame.origin.x - occupancyArray.count*imageForXSpacer.size.width)/(occupancyArray.count - 1);
    xPos = arrowView.frame.origin.x;
    yPos = emptyLabel.frame.origin.y - 10.0f - imageForXSpacer.size.height;
    
    for (NSUInteger i=0; i < occupancyArray.count; i++) {
        NSString *name = occupancyArray[i];
        UIButton *button = [self occupancyButtonWithName:name];
        button.frame = CGRectMake(xPos,
                                  yPos,
                                  button.bounds.size.width,
                                  button.bounds.size.height);
        [self.view addSubview:button];
        [self.buttons setObject:button forKey:name];
        
        xPos += button.frame.size.width + self.xSpacer;
    }
    
    CGFloat seperatorWidth = 0.8f*self.view.bounds.size.width;
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(.5*(self.view.bounds.size.width - seperatorWidth),
                                                                 yPos - 15.0f,
                                                                 seperatorWidth,
                                                                 1.0f)];
    seperator.backgroundColor = grey;
    [self.view addSubview:seperator];
}

- (CGRect)buttonFrameForButton:(UIButton *)button
                       atIndex:(NSUInteger)index
                  buttonsOnLine:(NSUInteger)buttonsOnLine
               andTotalButtons:(NSUInteger)totalButtons
                 withYPosition:(CGFloat)yPosition
{
    CGFloat xPosition = 0.0f;
    
    if (buttonsOnLine == 1) {
        xPosition = .5*self.view.bounds.size.width - .5*button.bounds.size.width;
    } else if (buttonsOnLine == 2) {
        NSUInteger xPos = index % kALFilterVCMaxColumns;
        xPosition = xPos/3.0f*self.view.bounds.size.width - button.bounds.size.width;
    } else if (buttonsOnLine == 3){
        xPosition = kALFilterVCXPadding + index*(button.bounds.size.width + self.xSpacer);
    }
    
    CGRect buttonFrame = CGRectMake(xPosition,
                                    yPosition,
                                    button.frame.size.width,
                                    button.frame.size.height);
    return buttonFrame;
}

- (NSUInteger)numberOfButtonsOnLineForButtonAtIndex:(NSUInteger)index maxNumberOfButtons:(NSUInteger)maxButtons
{
    NSUInteger counter = 1;
    NSUInteger upper = kALFilterVCMaxColumns;
    while (index >= upper) {
        counter++;
        upper = counter*kALFilterVCMaxColumns;
    }
    
    if (upper <= maxButtons) {
        return kALFilterVCMaxColumns;
    }
    
    return upper - maxButtons - 1;
}

- (UIButton *)filterButtonWithName:(NSString *)filterName
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    UIImage *filterIconActive = [ALProfilePicManager.manager iconForName:filterName
                                                                iconType:ALEventIconTypeFilter
                                                                isActive:YES];
    
    UIImage *filterIconNotActive = [ALProfilePicManager.manager iconForName:filterName
                                                                   iconType:ALEventIconTypeFilter
                                                                   isActive:NO];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  filterIconActive.size.width,
                                                                  filterIconActive.size.height)];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = .5*button.frame.size.width;
    button.selected = ![ALMapManager.manager isEventNameFiltered:filterName];
    [button setImage:filterIconActive forState:UIControlStateSelected];
    [button setImage:filterIconNotActive forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    
    return button;
}

- (UIButton *)occupancyButtonWithName:(NSString *)occupancyName
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    UIImage *filterIconActive = [ALProfilePicManager.manager iconForName:occupancyName
                                                                iconType:ALEventIconTypeDot
                                                                isActive:YES];
    
    UIImage *filterIconNotActive = [ALProfilePicManager.manager iconForName:occupancyName
                                                                   iconType:ALEventIconTypeDot
                                                                   isActive:NO];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  filterIconActive.size.width,
                                                                  filterIconActive.size.height)];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = .5*button.frame.size.width;
    button.selected = ![ALMapManager.manager isEventNameFiltered:occupancyName];
    [button setImage:filterIconActive forState:UIControlStateSelected];
    [button setImage:filterIconNotActive forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    
    return button;
}

- (void)buttonPressed:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.buttons enumerateKeysAndObjectsUsingBlock:^(NSString *key, UIButton *button, BOOL *stop) {
        if (button == sender) {
            button.selected = !button.isSelected;
            [ALMapManager.manager changeFilterStateForEventName:key];
            *stop = YES;
        }
    }];
}

- (NSString *)parseCamelCaseString:(NSString *)camelString
{
    NSMutableArray *splitIndexes = [NSMutableArray new];
    
    for (NSUInteger i=0; i < camelString.length; i++) {
        
        if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[camelString characterAtIndex:i]]) {
            [splitIndexes addObject:@(i)];
        }
    }
    
    NSMutableString *splitString;
    if (splitIndexes.count > 0) {
        NSMutableArray *parts = [NSMutableArray new];
        NSUInteger start = 0;
        for (NSUInteger i=0; i < splitIndexes.count; i++) {
            NSNumber *index = splitIndexes[i];
            NSRange range = NSMakeRange(start, index.integerValue);
            NSString *part = [camelString substringWithRange:range];
            
            [parts addObject:[part capitalizedString]];
            
            if (i == splitIndexes.count - 1) {
                part = [camelString substringFromIndex:index.integerValue];
                [parts addObject:part];
            }
            
            start = index.integerValue;
        }
        
        splitString = [NSMutableString new];
        for (NSUInteger i=0; i < parts.count; i++) {
            [splitString appendString:parts[i]];
            if (i < parts.count - 1) {
                [splitString appendString:@" "];
            }
        }
    }
    
    if (splitString) {
        return splitString;
    }

    return [camelString capitalizedString];
}

@end
