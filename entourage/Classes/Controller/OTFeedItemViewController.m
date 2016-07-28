//
//  OTTourViewController.m
//  entourage
//
//  Created by Nicolas Telera on 20/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

@import AddressBook;

// Controllers
#import "OTFeedItemViewController.h"
#import "UIViewController+menu.h"
#import "OTFeedItemDetailsOptionsViewController.h"
#import "OTUserViewController.h"
#import "OTMeetingCalloutViewController.h"
#import "OTConsts.h"
#import "OTFeedItemSummaryView.h"
#import "OTFeedItemInfoView.h"
#import "OTTourJoinRequestViewController.h"
#import "OTEntourageInviteSourceViewController.h"

// Models
#import "OTEntourage.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTOrganization.h"
#import "OTTourJoiner.h"
#import "OTEncounter.h"
#import "OTTourMessage.h"
#import "OTTourStatus.h"
#import "OTUser.h"
#import "OTFeedItemFactory.h"
#import "OTStateInfoDelegate.h"
#import "OTSpeechBehavior.h"

// Services
#import "OTTourService.h"
#import "OTEntourageService.h"

// Helpers
#import "UIColor+entourage.h"
#import "NSUserDefaults+OT.h"
#import "IQKeyboardManager.h"
#import "UIButton+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "SVProgressHUD.h"

#define IS_ACCEPTED ([self.feedItem.joinStatus isEqualToString:@"accepted"])

#define TAG_ORGANIZATION 1
#define TAG_TOURTYPE 2
#define TAG_TOURUSER 3

#define PADDING 10

typedef NS_ENUM(unsigned) {
    SectionTypeTimeline,
    SectionTypeHeader
    
} SectionType;



@interface OTFeedItemViewController () <UITextViewDelegate, OTFeedItemDetailsOptionsDelegate, OTFeedItemSummaryDelegate, OTTourJoinRequestDelegate, OTFeedItemInfoDelegate, InviteSourceDelegate>

@property (nonatomic, weak) IBOutlet OTFeedItemSummaryView *feedSummaryView;
@property (nonatomic, weak) IBOutlet UIButton *timelineButton;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (nonatomic, weak) IBOutlet UIView *timelineView;
@property (nonatomic, weak) IBOutlet OTFeedItemInfoView *infoView;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextView *chatTextView;
@property (nonatomic, weak) IBOutlet UIView *chatToolbar;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *distanceToSummaryConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *chatHConstraint;

@property (nonatomic, weak) IBOutlet OTSpeechBehavior *chatSpeechBehavior;

@property (nonatomic, strong) NSMutableArray *timelinePoints;
@property (nonatomic, strong) NSDictionary *timelineCardsClassesCellsIDs;

@end

@implementation OTFeedItemViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.chatSpeechBehavior initialize];
    self.title = [[_feedItem navigationTitle] uppercaseString];
    [self setupCloseModal];
    [self setupMoreButtons];
    
    [self.feedSummaryView setupWithFeedItem:self.feedItem];
    
    self.feedSummaryView.delegate = self;
    self.infoView.delegate = self;
    
    self.timelineCardsClassesCellsIDs = @{@"OTTourJoiner": @"TourJoinerCell",
                                          @"OTTourMessage": @"TourMessageCell",
                                          @"OTEncounter": @"TourEncounterCell",
                                          @"OTTourStatus": @"TourStatusCell"};
    
    if (IS_ACCEPTED) {
        [self initializeTimelinePoints];
        [self showTimeline];
    } else {
        
        self.timelineButton.hidden = YES;
        self.infoButton.hidden = YES;
        self.distanceToSummaryConstraint.constant = 0;
        [self showInfo];
    }
    
    self.chatTextView.layer.borderColor = [UIColor appGreyishColor].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNewMessage:)
                                                 name:@kNotificationNewMessage
                                               object:nil];
}

- (void)showNewMessage:(NSNotification*)notification {
    
    if ([self.feedItem isKindOfClass:[OTTour class]])
        [self getTourMessages];
    else
        [self getEntourageMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[self class]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (IS_ACCEPTED) {
        [self.chatSpeechBehavior updateRecordButton];
#warning remove existing items.
        [self initializeTimelinePoints];
        if ([self.feedItem isKindOfClass:[OTTour class]]) {
           
            [self getTourUsersJoins];
            [self getTourMessages];
            [self getTourEncounters];
        } else {
            //self.timelinePoints = [NSMutableArray new];
            [self getEntourageMessages];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)showTimeline {
    self.timelineView.hidden = NO;
    self.infoView.hidden = YES;
    [self.timelineButton setSelected:YES];
    [self.infoButton setSelected:NO];
    
    self.chatToolbar.hidden = NO;
}

- (IBAction)showInfo {
    self.timelineView.hidden = YES;
    self.infoView.hidden = NO;
    [self.timelineButton setSelected:NO];
    [self.infoButton setSelected:YES];
    self.chatToolbar.hidden = YES;
    [self.infoView setupWithFeedItem:self.feedItem];
}

/**************************************************************************************************/
#pragma mark - Private Methods

- (void)initializeTimelinePoints {
    self.timelinePoints = [NSMutableArray new];
    
    OTTourStatus *tourStartStatus = [[OTTourStatus alloc] init];
    tourStartStatus.date = self.feedItem.creationDate;
    tourStartStatus.type = OTTourStatusStart;
    tourStartStatus.status = [NSString stringWithFormat: OTLocalizedString(@"formatter_tour_status_ongoing"), self.feedItem.navigationTitle.capitalizedString];
    NSDate *now = [NSDate date];
    tourStartStatus.duration = [now timeIntervalSinceDate:self.feedItem.creationDate];
    tourStartStatus.distance = 0;
    //[self.timelinePoints addObject:tourStartStatus];
    [self updateTableViewAddingTimelinePoints:@[tourStartStatus]];
    
    
    if ([self.feedItem isKindOfClass:[OTTour class]]) {
        OTTour *tour = (OTTour*)self.feedItem;
        
        if (tour.endTime) {
            OTTourStatus *tourEndStatus = [[OTTourStatus alloc] init];
            tourEndStatus.date = tour.endTime;
            tourStartStatus.type = OTTourStatusEnd;
            tourEndStatus.status = OTLocalizedString(@"tour_status_completed");
            tourEndStatus.duration = [tour.endTime timeIntervalSinceDate:tour.creationDate];
            tourEndStatus.distance = tour.distance.doubleValue;
            [self updateTableViewAddingTimelinePoints:@[tourEndStatus]];
        }
    }
}

- (void)setupMoreButtons {
    if (IS_ACCEPTED) {
        if(![[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] canChangeEditState])
            return;
        UIBarButtonItem *plusButton = [UIBarButtonItem createWithImageNamed:@"userPlus" withTarget:self andAction:@selector(addUser)];
        UIBarButtonItem *moreButton = [UIBarButtonItem createWithImageNamed:@"more" withTarget:self andAction:@selector(showOptions)];
        [self.navigationItem setRightBarButtonItems:@[moreButton, plusButton]];
    } else {
        UIBarButtonItem *joinButton = [UIBarButtonItem createWithImageNamed:@"share" withTarget:self andAction:@selector(doJoinTour)];
        [self.navigationItem setRightBarButtonItem:joinButton];
    }
}

- (void)addUser {
    [self performSegueWithIdentifier:@"InviteSourceSegue" sender:nil];
}

#pragma mark - InviteSourceDelegate implementation

- (void)inviteContacts {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted) {
        [[[UIAlertView alloc] initWithTitle:OTLocalizedString(@"error") message:OTLocalizedString(@"addressBookDenied") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self performSegueWithIdentifier:@"InviteContactsSegue" sender:nil];
    } else {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted)
                    return;
                [self performSegueWithIdentifier:@"InviteContactsSegue" sender:nil];
            });
        });
    }
}

- (void)inviteByPhone {
    [self performSegueWithIdentifier:@"InvitePhoneSegue" sender:nil];
}

- (void)showOptions {
    [self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
}

- (void)doJoinTour {
    if ([self.feedItem.joinStatus isEqualToString:JOIN_NOT_REQUESTED])
        [self performSegueWithIdentifier:@"PublicJoinRequestSegue" sender:self];
}

- (void)updateTableViewAddingTimelinePoints:(NSArray *)timelinePoints {
    [self.timelinePoints addObjectsFromArray:timelinePoints];
    self.timelinePoints = [self.timelinePoints sortedArrayUsingSelector:@selector(compare:)].mutableCopy;
    [self.tableView reloadData];
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.timelinePoints.count-1 inSection:0];
     [self.tableView scrollToRowAtIndexPath:indexPath
                           atScrollPosition:UITableViewScrollPositionBottom
                                   animated:YES];
}


#pragma mark - Service
- (void)getTourUsersJoins {
    OTTour *tour = (OTTour *)self.feedItem;
    
    [[OTTourService new] tourUsersJoins:tour
                                success:^(NSArray *tourUsers) {
                                    //NSLog(@"USERS: %@", tourUsers);
                                    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
                                    NSMutableArray *users = [NSMutableArray new];
                                    for (OTTourJoiner *joiner  in tourUsers) {
                                        if ([joiner.uID isEqualToValue:currentUser.sid]) {
                                            continue;
                                        }
                                        if (![joiner.status isEqualToString:JOIN_ACCEPTED]) {
                                            continue;
                                        }
                                        [users addObject:joiner];
                                    }
                                    [self updateTableViewAddingTimelinePoints:users];
    } failure:^(NSError *error) {
        NSLog(@"USERS err %@", error.description);
    }];
}

- (void)getEntourageMessages {
    OTEntourage *entourage = (OTEntourage *)self.feedItem;
    [[OTEntourageService new] entourageMessagesForEntourage:entourage.uid
                                                WithSuccess:^(NSArray *entourageMessages) {
                                                    [self updateTableViewAddingTimelinePoints:entourageMessages];
                                                } failure:^(NSError * error) {
                                                    NSLog(@"MESSAGESerr %@", error.description);
                                                }];
}

- (void)getTourMessages {
    OTTour *tour = (OTTour *)self.feedItem;
    [[OTTourService new] tourMessages:tour
                                success:^(NSArray *tourMessages) {
                                    //NSLog(@"MESSAGES: %@", tourMessages);
                                    [self updateTableViewAddingTimelinePoints:tourMessages];

    } failure:^(NSError *error) {
        NSLog(@"MESSAGESerr %@", error.description);
    }];
}

- (void)getTourEncounters {
    OTTour *tour = (OTTour *)self.feedItem;
    [[OTTourService new] tourEncounters:tour
                              success:^(NSArray *tourEncounters) {
                                  [self updateTableViewAddingTimelinePoints:tourEncounters];
                              } failure:^(NSError *error) {
                                  NSLog(@"ENCOUNTERSSerr %@", error.description);
                              }];
}

- (IBAction)sendMessage {
    [self.chatTextView resignFirstResponder];
    [[[OTFeedItemFactory createFor:self.feedItem] getMessaging] send:self.chatTextView.text withSuccess:^(OTTourMessage *message) {
        self.chatTextView.text = @"";
        [self updateTableViewAddingTimelinePoints:@[message]];
        [self.chatSpeechBehavior updateRecordButton];
    } orFailure:^(NSError *error) {
        NSLog(@"send message failure %@", error.description);
    }];
}

/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithTour:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
}

- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"EEE"];
    return [formatter stringFromDate:date];
}

- (NSString *)formatHourForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH':'mm"];
    return [formatter stringFromDate:date];
}

- (NSString *)formatHourToSecondsForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatter setDateFormat:@"HH':'mm':'ss"];
    return [formatter stringFromDate:date];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**************************************************************************************************/
#pragma mark - OTFeedItemDetailsOptionsDelegate

- (void)promptToCloseFeedItem {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate promptToCloseTour];
    }];
}

- (void)feedItemFrozen:(OTFeedItem *)item {
    self.feedItem = item;
    self.chatToolbar.hidden = YES;
    [self.navigationItem setRightBarButtonItems:nil];
}

/**************************************************************************************************/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timelinePoints.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"";
    switch (indexPath.section) {
        case SectionTypeTimeline: {
            NSString *timelinePointClassName = NSStringFromClass([ self.timelinePoints[indexPath.row] class]);
            cellID = [self.timelineCardsClassesCellsIDs valueForKey:timelinePointClassName];
        }
            break;
        default:
            break;
    }

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    switch (((OTTourTimelinePoint *)self.timelinePoints[indexPath.row]).tag) {
        case TimelinePointTagEncounter:
            [self setupEncounterCell:cell withEncounter:((OTEncounter *)self.timelinePoints[indexPath.row])];
            break;
        case TimelinePointTagJoiner:
            [self setupJoinerCell:cell withJoiner:((OTTourJoiner *)self.timelinePoints[indexPath.row])];
            break;
        case TimelinePointTagMessage:
            [self setupMessageCell:cell withMessage:((OTTourMessage *)self.timelinePoints[indexPath.row])];
            break;
        case TimelinePointTagStatus:
            [self setupStatusCell:cell withStatus:((OTTourStatus *)self.timelinePoints[indexPath.row])];
            break;
            
        default:
            break;
    }
    
    return cell;
}

#define TIMELINE_TIME_TAG 10
#define TIMELINE_STATUS_TAG 11
#define TIMELINE_DURATION_TAG 12
#define TIMELINE_KM_TAG 13
#define TIMELINE_STATUS_IMAGE 20


#define TIMELINE_MESSAGE_OTHER_BACKGROUND_TAG 30
#define TIMELINE_MESSAGE_OTHER_USER 31
#define TIMELINE_MESSAGE_OTHER_TEXT 32
#define TIMELINE_MESSAGE_OTHER_NAME 40

#define TIMELINE_MESSAGE_OTHER_CONTENT_TAG 33
#define TIMELINE_MESSAGE_ME_CONTENT_TAG 34

#define TIMELINE_MESSAGE_ME_BACKGROUND_TAG 35
#define TIMELINE_MESSAGE_ME_TEXT 36

#define TIMELINE_ENCOUNTER 100
#define TIMELINE_JOINER 200

- (void)setupEncounterCell:(UITableViewCell *)cell withEncounter:(OTEncounter *)encounter {
    //User et Encounter se sont rencontrés ici.
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightLight]};
    NSDictionary *boldAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold],
                                NSForegroundColorAttributeName: [UIColor appOrangeColor]};
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", encounter.userName] attributes:boldAttrs];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:OTLocalizedString(@"formatter_encounter_and_user_meet") , encounter.streetPersonName] attributes:lightAttrs];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    UILabel *encounterLabel = [cell viewWithTag:TIMELINE_ENCOUNTER];
    encounterLabel.attributedText = typeByNameAttrString;
}

- (void)setupJoinerCell:(UITableViewCell *)cell withJoiner:(OTTourJoiner *)joiner {
    
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightLight]};
    NSDictionary *boldAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold],
                                NSForegroundColorAttributeName: [UIColor appOrangeColor]};
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", joiner.displayName] attributes:boldAttrs];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:OTLocalizedString(@"user_joined_tour")  attributes:lightAttrs];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    UILabel *joinerLabel = [cell viewWithTag:TIMELINE_JOINER];
    joinerLabel.attributedText = typeByNameAttrString;
}

- (void)setupMessageCell:(UITableViewCell *)cell withMessage:(OTTourMessage *)message {
    
    UIView *messageOtherContainer = [cell viewWithTag:TIMELINE_MESSAGE_OTHER_CONTENT_TAG];
    UIView *messageMeContainer = [cell viewWithTag:TIMELINE_MESSAGE_ME_CONTENT_TAG];
    
    UIImageView *messageBackgroundImageView = nil;
    UILabel *messageLabel = nil;
    UIImage *backgroundImage = nil;
    
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.sid intValue] == [message.uID intValue]) {
        [messageMeContainer setHidden:NO];
        [messageOtherContainer setHidden:YES];
        
        messageBackgroundImageView = [cell viewWithTag:TIMELINE_MESSAGE_ME_BACKGROUND_TAG];
        messageLabel = [cell viewWithTag:TIMELINE_MESSAGE_ME_TEXT];
        backgroundImage = [UIImage imageNamed:@"bubbleDiscussion"];
        
    } else {
        [messageMeContainer setHidden:YES];
        [messageOtherContainer setHidden:NO];
        
        UILabel *nameLabel = [cell viewWithTag:TIMELINE_MESSAGE_OTHER_NAME];
        nameLabel.text = message.userName;
        
        messageBackgroundImageView = [cell viewWithTag:TIMELINE_MESSAGE_OTHER_BACKGROUND_TAG];
        messageLabel = [cell viewWithTag:TIMELINE_MESSAGE_OTHER_TEXT];
        backgroundImage = [UIImage imageNamed:@"bubbleDiscussionGrey"];
        
        UIButton *userImageButton = [cell viewWithTag:TIMELINE_MESSAGE_OTHER_USER];
        [userImageButton setupAsProfilePictureFromUrl:message.userAvatarURL];
    }
    
    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    messageLabel.text = message.text;
    messageBackgroundImageView.image = backgroundImage;
}

- (void)setupStatusCell:(UITableViewCell *)cell withStatus:(OTTourStatus *)statusPoint {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *snapshotFormat = statusPoint.type == OTTourStatusStart ? @SNAPSHOT_START : @SNAPSHOT_STOP;
    NSString *snapshotStartFilename = [NSString stringWithFormat:snapshotFormat, self.feedItem.uid.intValue];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:snapshotStartFilename];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    // TIMELINE_STATUS_IMAGE
    UIImageView *mapImageView = [cell viewWithTag:TIMELINE_STATUS_IMAGE];
    [mapImageView setImage:image];
    
    UILabel *timeLabel = [cell viewWithTag:TIMELINE_TIME_TAG];
    NSString *day  = [self formatDateForDisplay:statusPoint.date];
    NSString *time = [self formatHourForDisplay:statusPoint.date];
    
    timeLabel.text = [NSString stringWithFormat:@"%@ %@", [day uppercaseString], time];
    
    UILabel *statusLabel = [cell viewWithTag:TIMELINE_STATUS_TAG];
    statusLabel.text = statusPoint.status;
    
    UILabel *durationLabel = [cell viewWithTag:TIMELINE_DURATION_TAG];
    UILabel *kmLabel = [cell viewWithTag:TIMELINE_KM_TAG];
    if ([self.feedItem isKindOfClass:[OTTour class]]) {
        durationLabel.text = [self formatHourToSecondsForDisplay:[NSDate dateWithTimeIntervalSince1970: statusPoint.duration]];
        kmLabel.text = [NSString stringWithFormat:@"%.2fkm", statusPoint.distance / 1000.0f]; //distance is in meters
    } else {
        durationLabel.text = @"";
        kmLabel.text = @"";
    }

}

- (void)doShowProfile {
    [self performSegueWithIdentifier:@"OTUserProfileSegue" sender:self.feedItem.author.uID];
}


#define CELLHEIGHT_HEADER 70.0f
#define CELLHEIGHT_JOINER 49.0f
#define CELLHEIGHT_ENCOUNTER 49.0f
#define CELLHEIGHT_STATUS 157.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionTypeHeader:
            return CELLHEIGHT_HEADER;
        case SectionTypeTimeline: {
            OTTourTimelinePoint *timelinePoint = self.timelinePoints[indexPath.row];
            if ([timelinePoint isKindOfClass:[OTTourJoiner class]])
                return CELLHEIGHT_JOINER;
            if ([timelinePoint isKindOfClass:[OTEncounter class]])
                return CELLHEIGHT_ENCOUNTER;
            if ([timelinePoint isKindOfClass:[OTTourMessage class]]) {
                OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
                OTTourMessage *message = (OTTourMessage*)timelinePoint;
                CGFloat otherUserDelta = PADDING;
                if ([currentUser.sid intValue] != [message.uID intValue])
                    otherUserDelta = 2*PADDING;
                return otherUserDelta + [self messageHeightForText:message.text];
            }
            if ([timelinePoint isKindOfClass:[OTTourStatus class]])
                return CELLHEIGHT_STATUS;
        }
        default:
            return 0.0f;
    }
}
                 
- (CGFloat)messageHeightForText:(NSString *)messageContent {
    CGSize maximumLabelSize = CGSizeMake(220, FLT_MAX);
    UIFont *fontText = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    CGSize expectedLabelSize = [messageContent boundingRectWithSize:maximumLabelSize
                                                 options:(NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading)
                                              attributes:@{NSFontAttributeName:fontText}
                                                 context:nil].size;

    return expectedLabelSize.height + 4*PADDING;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SectionTypeTimeline) {
        OTTourTimelinePoint *timelinePoint = self.timelinePoints[indexPath.row];
        switch (timelinePoint.tag) {
            case TimelinePointTagJoiner:
                {
                    OTTourJoiner *joinerPoint = (OTTourJoiner *)timelinePoint;
                    [self performSegueWithIdentifier:@"OTUserProfileSegue" sender:joinerPoint.uID];
                }
                break;
            case TimelinePointTagEncounter:
                {
                    OTEncounter *encounter = (OTEncounter *)timelinePoint;
                    if ([encounter.userId isEqualToValue:self.feedItem.author.uID]) {
                        //show the encounter
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        OTMeetingCalloutViewController *controller = (OTMeetingCalloutViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"OTMeetingCalloutViewController"];
                        [controller setEncounter:encounter];
                        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                        [self presentViewController:navController animated:YES completion:nil];
                    }
                    else {
                        //show the user profile
                        [self performSegueWithIdentifier:@"OTUserProfileSegue" sender:encounter.userId];
                    }
                }
                break;
                
            default:
                break;
        }
    }
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

#pragma mark - UITextFieldDelegate

#define TEXTFIELD_HEIGHT_MIN 30.f

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"Text view did change...");
    [self.chatSpeechBehavior updateRecordButton];

    UIFont *fontText = textView.font;
    CGSize newSize = [textView.text boundingRectWithSize:CGSizeMake(224, 80)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading)
                                              attributes:@{NSFontAttributeName:fontText}
                                                 context:nil].size;
    self.chatHConstraint.constant = MAX(TEXTFIELD_HEIGHT_MIN, newSize.height + PADDING);
}

#pragma mark - UIKeyboard

static CGFloat keyboardOverlap;

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    // Get the keyboard size
    UIScrollView *tableView;
    if ([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    // Get the keyboard's animation details
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    // Determine how much overlap exists between tableView and the keyboard
    CGRect tableFrame = tableView.frame;
    CGFloat tableLowerYCoord = tableFrame.origin.y + tableFrame.size.height;
    keyboardOverlap = tableLowerYCoord - keyboardRect.origin.y ;
    
    self.bottomConstraint.constant = keyboardRect.size.height;
    
    if (self.inputAccessoryView && keyboardOverlap>0)
    {
        CGFloat accessoryHeight = self.inputAccessoryView.frame.size.height;
        keyboardOverlap -= accessoryHeight;
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, accessoryHeight, 0);
    }
    
    if (keyboardOverlap < 0)
        keyboardOverlap = 0;
    
    if (keyboardOverlap != 0)
    {
        tableFrame.size.height -= keyboardOverlap;
        
        NSTimeInterval delay = 0;
        if (keyboardRect.size.height)
        {
            delay = (1 - keyboardOverlap/keyboardRect.size.height)*animationDuration;
            animationDuration = animationDuration * keyboardOverlap/keyboardRect.size.height;
        }
        
        [UIView animateWithDuration:animationDuration delay:delay
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{ tableView.frame = tableFrame; }
                         completion:^(BOOL finished){
                             [self tableAnimationEnded:nil finished:nil contextInfo:nil];
                         }];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    
    self.chatHConstraint.constant = 30.f;
    
    UIScrollView *tableView;
    if ([self.tableView.superview isKindOfClass:[UIScrollView class]])
        tableView = (UIScrollView *)self.tableView.superview;
    else
        tableView = self.tableView;
    if (self.inputAccessoryView)
    {
        tableView.contentInset = UIEdgeInsetsZero;
        tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    if (keyboardOverlap == 0)
        return;
    
    // Get the size & animation details of the keyboard
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [tableView.superview convertRect:[aValue CGRectValue] fromView:nil];
    
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height += keyboardOverlap;
    
    if (keyboardRect.size.height)
        animationDuration = animationDuration * keyboardOverlap/keyboardRect.size.height;
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         tableView.frame = tableFrame;
                         self.bottomConstraint.constant = 0.f;
                     }
                     completion:nil];
}

- (void) tableAnimationEnded:(NSString*)animationID finished:(NSNumber *)finished contextInfo:(void *)context
{
    // Scroll to the active cell
    //    if(self.activeCellIndexPath)
    //    {
    //        [self.tableView scrollToRowAtIndexPath:self.activeCellIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    //        [self.tableView selectRowAtIndexPath:self.activeCellIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    //    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OTTourOptionsSegue"]) {
        OTFeedItemDetailsOptionsViewController *controller = (OTFeedItemDetailsOptionsViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
        controller.view.backgroundColor = [UIColor appModalBackgroundColor];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.delegate  = self;
    }
    else if ([segue.identifier isEqualToString:@"OTUserProfileSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTUserViewController *controller = (OTUserViewController*)navController.topViewController;
        controller.userId = (NSNumber *)sender;
    }
    else if ([segue.identifier isEqualToString:@"PublicJoinRequestSegue"]) {
        OTTourJoinRequestViewController *controller = (OTTourJoinRequestViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.feedItem = self.feedItem;
        controller.tourJoinRequestDelegate = self;
    }
    else if ([segue.identifier isEqualToString:@"InviteSourceSegue"]) {
        OTEntourageInviteSourceViewController *controller = (OTEntourageInviteSourceViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
}

/********************************************************************************/
#pragma mark - OTTourJoinRequestDelegate
- (void)dismissTourJoinRequestController {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed join screen");
        //[self setupUI];
    }];
}


@end
