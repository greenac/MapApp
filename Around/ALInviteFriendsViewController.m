//
//  ALInviteFriendsViewController.m
//  Banter!
//
//  Created by Andre Green on 10/10/14.
//  Copyright (c) 2014 Andre Green. All rights reserved.
//

#import "ALInviteFriendsViewController.h"
#import "ALContact.h"
#import "ALInviteFriendsTableViewCell.h"
#import "ALEvent.h"
#import "ALScene.h"
#import "ALJumpToNameLetterView.h"
#import "ALJumpToContactLetterView.h"
#import "ALInviteFriendsNameView.h"
#import "ALProfilePicManager.h"
#import "ALSegues.h"
#import <QuartzCore/QuartzCore.h>

#define kALInviteFriendsTableViewHeight     40.0f
#define kALBanterGreen                      [UIColor colorWithRed:3.0f/255.0f green:177.0f/255.0f blue:146.0/255.0f alpha:1.0f]
#define kALInviteFriendsGrey                [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0/255.0f alpha:1.0f]
#define kALInviteFriendsMaxNumberContacts   3
#define kALInviteFriendsButtonXOffset       10.0f
#define kALInviteFriendsButtonYOffset       5.0f
#define kALInviteFriendsButtonHeight        15.0f
#define kALInviteFriendsButtonWidth         100.0f

@interface ALInviteFriendsViewController ()

@property (nonatomic, strong) UIImageView *lockView;
@property (nonatomic, strong) NSMutableArray *allContacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSMutableArray * contacts;
@property (nonatomic, strong) NSMutableDictionary *selectedNameViews;
@property (nonatomic, assign) CGFloat scrollViewInitialHeight;
@property (nonatomic, strong) ALJumpToContactLetterView *jumpToContactViewContainer;
@property (nonatomic, assign) CGRect searchFieldOriginalFrame;

@end

@implementation ALInviteFriendsViewController

- (void)viewDidLoad
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self checkAddressBookStatus];
    
    self.scrollViewInitialHeight = self.addedContactScrollView.frame.size.height;
    
    NSString *nameLabelText = [self defaultText];
    if (self.event) {
        UIImage *icon = [ALProfilePicManager.manager iconForEvent:self.event
                                                         iconType:ALEventIconTypeDot];
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      25.0f,
                                                                      25.0f)];
        self.iconView.image = icon;
        self.iconView.alpha = 0.0f;
        self.iconView.clipsToBounds = NO;
        [self.eventInfoView addSubview:self.iconView];
        
        nameLabelText = self.event.scene.name;
    }
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.text = nameLabelText;
    self.nameLabel.font = [UIFont systemFontOfSize:12.0f];
    self.nameLabel.alpha = 0.0f;
    [self.eventInfoView addSubview:self.nameLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // place name label and pic
    CGSize iconSize = self.iconView ? self.iconView.frame.size : CGSizeZero;
    CGFloat leftBound = CGRectGetMaxX(self.cancelButton.frame);
    CGFloat rightBound = self.sendButton.frame.origin.x;
    CGFloat nameLabelMaxWidth = rightBound - leftBound - iconSize.width;
    
    CGSize maxSize = CGSizeMake(nameLabelMaxWidth, self.hoursLabel.frame.size.height);
    
    CGRect nameLabelRect = [self.nameLabel.text boundingRectWithSize:maxSize
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:self.nameLabel.font}
                                                             context:nil];
    
    self.nameLabel.alpha = 0.0f;
    self.nameLabel.frame = CGRectMake(self.hoursLabel.center.x - .5*nameLabelRect.size.width,
                                      self.hoursLabel.frame.origin.y - nameLabelRect.size.height - 3.0f,
                                      nameLabelRect.size.width,
                                      nameLabelRect.size.height);
    
    if (self.iconView) {
        self.iconView.alpha = 0.0f;
        self.iconView.frame = CGRectMake(self.nameLabel.frame.origin.x - self.iconView.frame.size.width - 3.0f,
                                         self.nameLabel.center.y - .5*self.iconView.frame.size.height,
                                         self.iconView.frame.size.width,
                                         self.iconView.frame.size.height);
    }
    
    [UIView animateWithDuration:.1f animations:^{
        self.nameLabel.alpha = 1.0f;
        if (self.iconView) {
            self.iconView.alpha = 1.0f;
        }
    }];
}
- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (NSMutableArray *)allContacts
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_allContacts) {
        _allContacts = [NSMutableArray new];
    }
    return _allContacts;
}

- (NSMutableArray *)contacts
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_contacts) {
        _contacts = [NSMutableArray new];
    }
    return _contacts;
}

- (NSMutableArray *)selectedContacts
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_selectedContacts) {
        _selectedContacts = [NSMutableArray new];
    }
    return _selectedContacts;
}

- (NSMutableDictionary *)selectedNameViews
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_selectedNameViews) {
        _selectedNameViews = [NSMutableDictionary new];
    }
    return _selectedNameViews;
}

- (void)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *lockViewName;
        if ([UIScreen mainScreen].bounds.size.height <= 481.0f) {
            lockViewName = @"splash_screen4";
        } else {
            lockViewName = @"splash_screen5";
        }
        
        UIImage *lockImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", lockViewName]];
        self.lockView = [[UIImageView alloc] initWithImage:lockImage];
        [self.view addSubview:self.lockView];
    });
}

- (void)unlock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lockView removeFromSuperview];
        self.lockView = nil;
    });
}

- (void)checkAddressBookStatus
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        [self lock];
        [self presentAddressBookAccessDeniedAlertView];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        [self unlock];
        [self fillAllContactsWithCompletion:^{
            [self prepareView];
        }];
    } else{
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (granted){
                [self unlock];
                [self fillAllContactsWithCompletion:^{
                    [self prepareView];
                }];
            } else {
                [self lock];
                [self presentAddressBookAccessDeniedAlertView];
            }
        });
    }
}

- (void)presentAddressBookAccessDeniedAlertView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = NSLocalizedString(@"To invite friends please go to your phone's settings and enable contacts under privacy", nil);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Banter! can't invite friends"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)prepareView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = kALInviteFriendsTableViewHeight;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView reloadData];
    
    if (self.event) {
        UIImage *icon = [ALProfilePicManager.manager iconForEvent:self.event
                                                         iconType:ALEventIconTypeDot];
        self.iconView.image = icon;
        self.nameLabel.text = self.event.scene.name;
        self.hoursLabel.text = [self.event hoursForToday];
    } else {
        self.hoursLabel.text = @"";
        self.nameLabel.text = NSLocalizedString(@"Invite Friends To Use Banter!", nil);
    }
    
    self.eventInfoView.backgroundColor = kALBanterGreen;
    
    self.searchField.placeholder = NSLocalizedString(@"Search", nil);
    self.searchField.returnKeyType = UIReturnKeyDone;
    self.searchField.delegate = self;

    self.searchFieldOriginalFrame = self.searchField.frame;
    
    [self.exitSearchButton setTitleColor:kALBanterGreen forState:UIControlStateNormal];
    self.exitSearchButton.hidden = YES;
    
    CGFloat contactLabelGreyValue = 199.0f/255.0f;
    self.contactListLabel.text = NSLocalizedString(@"Contact List", nil);
    self.contactListLabel.textColor = [UIColor colorWithRed:contactLabelGreyValue
                                                      green:contactLabelGreyValue
                                                       blue:contactLabelGreyValue
                                                      alpha:1.0f];
    self.contactListLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    
    //[self createJumpToLetterView];
}

- (ALInviteFriendsNameView *)makeNameView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    CGRect frame = [self selectedContactButtonFrameForIndex:self.selectedContacts.count-1];
    ALContact *contact = [self.selectedContacts lastObject];
    
    ALInviteFriendsNameView *nameView = [[ALInviteFriendsNameView alloc] initWithFrame:frame];
    nameView.delegate = self;
    nameView.nameLabel.text = contact.fullName;
    nameView.tag = contact.idNumber;
    
    self.selectedNameViews[@(contact.idNumber)] = nameView;
    
    return nameView;
}

- (CGRect)selectedContactButtonFrameForIndex:(NSUInteger)index
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSInteger yPosition = index / kALInviteFriendsMaxNumberContacts;
    NSInteger xPosition = index % kALInviteFriendsMaxNumberContacts;
    static CGFloat xSpacer = 3.0f;
    
    CGFloat xInset = 0.0f;
    if (xPosition == 0) {
        xInset = xSpacer;
    } else if (xPosition == 2){
        xInset = -xSpacer;
    }
    
    static CGFloat yInset = 1.0f;
    
    return CGRectMake(xPosition*(kALInviteFriendsButtonXOffset + kALInviteFriendsButtonWidth) + xInset,
                      yPosition*(kALInviteFriendsButtonYOffset + kALInviteFriendsButtonHeight) + yInset,
                      kALInviteFriendsButtonWidth,
                      kALInviteFriendsButtonHeight);
}

- (void)addNameViewToContactScrollView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.addedContactScrollView addSubview:[self makeNameView]];
}

- (void)setAddedContactScrollViewContentSize
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSInteger yPosition = self.selectedContacts.count / kALInviteFriendsMaxNumberContacts;
    CGFloat currentHeight = yPosition*(kALInviteFriendsButtonYOffset + kALInviteFriendsButtonHeight) + kALInviteFriendsButtonHeight;
    
    CGSize contentSize;
    if (currentHeight > self.scrollViewInitialHeight) {
        contentSize = CGSizeMake(self.addedContactScrollView.bounds.size.width, currentHeight);
    } else {
        contentSize = CGSizeMake(self.addedContactScrollView.bounds.size.width, self.scrollViewInitialHeight);
    }
    
    self.addedContactScrollView.contentSize = contentSize;
}

- (void)createJumpToLetterView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static CGFloat viewWidth = 20.0f;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat viewHeight = self.view.bounds.size.height - statusBarHeight;
    CGRect viewFrame = CGRectMake(self.view.bounds.size.width - viewWidth,
                                  statusBarHeight,
                                  viewWidth,
                                  viewHeight);
    
    self.jumpToContactViewContainer = [[ALJumpToContactLetterView alloc] initWithFrame:viewFrame];
    self.jumpToContactViewContainer.backgroundColor = kALInviteFriendsGrey;
    self.jumpToContactViewContainer.parentController = self;
    self.jumpToContactViewContainer.layer.cornerRadius = 4.0f;
    
    //[self.view addSubview:self.jumpToContactViewContainer];
}

- (void)moveTableToFirstLetter:(NSString *)letter
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSUInteger counter = 0;
    for (ALContact *contact in self.contacts) {
        NSString *firstLetter = [NSString stringWithFormat:@"%c",[contact.firstName characterAtIndex:0]];
        if ([firstLetter compare:letter options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            break;
        }
        
        counter++;
    }
    
    if (counter < self.contacts.count) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:counter inSection:0];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)searchContacts:(NSString *)text
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([text isEqualToString:@""]) {
        self.contacts = [NSMutableArray arrayWithArray:self.allContacts];
        return;
    }
    
    NSString *searchText = text.lowercaseString;
    [self.contacts removeAllObjects];
    
    for (ALContact *contact in self.allContacts) {
        NSString *fullName = [contact fullName].lowercaseString;
        if ([fullName rangeOfString:searchText].location != NSNotFound) {
            [self.contacts addObject:contact];
        }
    }
}

- (void)fillAllContactsWithCompletion:(void(^)(void))completionBlock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    __block NSMutableArray *allContactsArray = [NSMutableArray new];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (!addressBook) {
            return;
        }
        
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (int i = 0; i < allContacts.count; i++) {
            ABRecordRef person = (__bridge ABRecordRef)allContacts[i];
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            /*
             NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
             contacts.image = [UIImage imageWithData:imgData];
             if (!contacts.image) {
             contacts.image = [UIImage imageNamed:@"NOIMG.png"];
             }
             */
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef numbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0; i < ABMultiValueGetCount(numbers); i++) {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(numbers, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [phoneNumbers addObject:phoneNumber];
            }
            
            NSString *phoneNumber = [phoneNumbers firstObject];
            
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                
                [contactEmails addObject:contactEmail];
            }
            
            NSString *email = [contactEmails firstObject];
            if (firstName && phoneNumber) {
                ALContact *contact = [[ALContact alloc] initWithFirstName:firstName
                                                                 lastName:lastName
                                                                    email:email
                                                              phoneNumber:phoneNumber];
                [allContactsArray addObject:contact];
            }
            
            [allContactsArray sortUsingComparator:^NSComparisonResult(ALContact *contact1, ALContact *contact2) {
                return [contact1.firstName compare:contact2.firstName options:NSCaseInsensitiveSearch];
            }];
        }
        
        for (NSUInteger i=0; i < allContactsArray.count; i++) {
            ALContact *contact = allContactsArray[i];
            contact.idNumber = i;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.allContacts = [NSMutableArray arrayWithArray:allContactsArray];
            self.contacts = [NSMutableArray arrayWithArray:self.allContacts];
            if (completionBlock) {
                completionBlock();
            }
        });
    });
    
}

- (void)insertContactIntoContacts:(ALContact *)contact fromLeftIndex:(NSInteger)leftIndex toRightIndex:(NSInteger)rightIndex
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (rightIndex == leftIndex) {
        self.contacts[leftIndex] = contact;
        return;
    }
    
    NSInteger middle = (rightIndex + leftIndex) / 2;
    
    ALContact *contactAtIndex = self.contacts[middle];
    
    if ([contact.firstName compare:contactAtIndex.firstName options:NSCaseInsensitiveSearch] == NSOrderedAscending) {
        // contact's firstname is comes before contact at index's first name
        [self insertContactIntoContacts:contact fromLeftIndex:leftIndex toRightIndex:middle];
    } else {
        [self insertContactIntoContacts:contact fromLeftIndex:middle + 1 toRightIndex:rightIndex];
    }
}

- (void)presentTextMessageViewController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        NSMutableArray *numbers = [NSMutableArray new];
        for (ALContact *contact in self.selectedContacts) {
            [numbers addObject:contact.phoneNumber];
        }
        
        NSString *message;
        if (self.event) {
            message = [NSString stringWithFormat:@"Wanna come check this out today?\n%@ %@ - %@\n%@\nSent via Banter!www.thebanterapp.com/download",
                                 self.event.scene.name,
                                [self.event parseEventType],
                                [self.event hoursForToday],
                                self.event.message];
        } else {
            message = [self defaultText];
        }
        
        controller.body = message;
        controller.recipients = numbers;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable To Send Message", nil)
                                                        message:@"Banter! can't send this message right now. Try later or use another device"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (NSString *)defaultText
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSString *text = NSLocalizedString(@"You should download Banter! All nearby happy hours, live music and food trucks, in real time, through a single app!\nhttp://www.thebanterapp.com", nil);
    
    return text;
}

#pragma mark - IBActions and other actions
- (IBAction)sendButtonPressed:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self presentTextMessageViewController];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (self.fromTutorial) {
        [self performSegueWithIdentifier:kALSegueInviteFriendsToMap sender:sender];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)exitSearchButtonPressed:(id)sender
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.searchField resignFirstResponder];
}

- (void)removeNameView:(ALInviteFriendsNameView *)nameView forContact:(ALContact *)contact atIndex:(NSUInteger)index
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [self.selectedContacts removeObject:contact];

    [UIView animateWithDuration:.2f animations:^{
        nameView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [nameView removeFromSuperview];
        [self.selectedNameViews removeObjectForKey:@(contact.idNumber)];
        
        for (NSUInteger i=index; i < self.selectedContacts.count; i++) {
            ALContact *moveContact = self.selectedContacts[i];
            ALInviteFriendsNameView *movedView = self.selectedNameViews[@(moveContact.idNumber)];
            movedView.frame = [self selectedContactButtonFrameForIndex:i];
        }
        
        [self setAddedContactScrollViewContentSize];
        
        contact.isSelected = NO;
        
        NSIndexPath *targetPath = [NSIndexPath indexPathForRow:contact.idNumber inSection:0];
        //ALInviteFriendsTableViewCell *cell = (ALInviteFriendsTableViewCell *)[self.tableView cellForRowAtIndexPath:targetPath];
        [self.tableView reloadRowsAtIndexPaths:@[targetPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if (self.selectedContacts.count == 0) {
            self.inviteFriendsLabel.hidden = NO;
        }
    }];
}

#pragma mark - invite friends name view delegate methods
- (void)inviteFriendsNameViewTouched:(ALInviteFriendsNameView *)nameView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // remove contact from scroll view, rearrange all views in scroll view,
    // and change add button in cell to enabled
    
    ALContact *touchedContact;
    NSUInteger touchedIndex = 0;
    for (ALContact *contact in self.selectedContacts) {
        if (contact.idNumber == nameView.tag) {
            touchedContact = contact;
            break;
        }
        touchedIndex++;
    }

    [self removeNameView:nameView forContact:touchedContact atIndex:touchedIndex];
}

#pragma mark alert view delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (buttonIndex == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - tableview delegate & datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ALInviteFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ALInviteFriendsTableViewCell"];
    
    CGFloat nameGreyValue = 106.0f/255.0f;
    CGFloat phoneNumberGreyValue = 179.0f/255.0f;
    
    ALContact *contact = self.contacts[indexPath.row];
    
    cell.nameLabel.text = [contact fullName];
    cell.nameLabel.textColor = [UIColor colorWithRed:nameGreyValue green:nameGreyValue blue:nameGreyValue alpha:1.0f];
    cell.phoneNumberLabel.text = contact.phoneNumber;
    cell.phoneNumberLabel.textColor = [UIColor colorWithRed:phoneNumberGreyValue green:phoneNumberGreyValue blue:phoneNumberGreyValue alpha:1.0f];
    
    cell.addContactButton.selected = contact.isSelected;
    [cell.addContactButton setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
    [cell.addContactButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.row;
    
    return cell;
}

#pragma mark invite friends cell delegate methods
- (void)inviteFriendsTableViewCellAddContactButtonPushed:(ALInviteFriendsTableViewCell *)cell
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    ALContact *contact = self.contacts[cell.tag];
    
    if (contact.isSelected) {
        NSUInteger location = [self.selectedContacts indexOfObject:contact];
        ALInviteFriendsNameView *nameView = self.selectedNameViews[@(contact.idNumber)];
        [self removeNameView:nameView forContact:contact atIndex:location];
    } else {
        self.inviteFriendsLabel.hidden = YES;
        contact.isSelected = YES;
        
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.selectedContacts addObject:contact];
        [self addNameViewToContactScrollView];
        [self setAddedContactScrollViewContentSize];
        
        [self.addedContactScrollView scrollRectToVisible:CGRectMake(0.0f,
                                                                    self.addedContactScrollView.contentSize.height - self.addedContactScrollView.frame.size.height,
                                                                    self.addedContactScrollView.bounds.size.width,
                                                                    self.addedContactScrollView.bounds.size.height)
                                                animated:YES];
    }
}

#pragma mark - jump to letter view delegate methods
- (void)jumpToLetterViewSelected:(ALJumpToNameLetterView *)letterView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self moveTableToFirstLetter:letterView.letter];
}

#pragma mark - message compose view controller delegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [controller dismissViewControllerAnimated:NO completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - text field delegate functions
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [UIView animateWithDuration:.2f animations:^{
        self.searchField.frame = CGRectMake(self.searchFieldOriginalFrame.origin.x,
                                            self.searchFieldOriginalFrame.origin.y,
                                            self.searchFieldOriginalFrame.size.width - 1.2*self.exitSearchButton.bounds.size.width,
                                            self.searchFieldOriginalFrame.size.height);
    } completion:^(BOOL finished) {
        self.exitSearchButton.hidden = NO;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [UIView animateWithDuration:.2f animations:^{
        self.searchField.frame = self.searchFieldOriginalFrame;
    } completion:^(BOOL finished) {
        self.exitSearchButton.hidden = YES;
    }];
    
    self.searchField.text = @"";
    self.contacts = [NSMutableArray arrayWithArray:self.allContacts];
    [self.tableView reloadData];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];

    [self searchContacts:text];
    
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.searchField) {
        [self.searchField resignFirstResponder];
    }
    
    return YES;
}
@end
