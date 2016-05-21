//
//  OTTourViewController.m
//  entourage
//
//  Created by Nicolas Telera on 20/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

// Controllers
#import "OTFeedItemViewController.h"
#import "UIViewController+menu.h"
#import "OTTourDetailsOptionsViewController.h"
#import "OTUserViewController.h"
#import "OTMeetingCalloutViewController.h"
#import "OTConsts.h"
#import "OTFeedItemSummaryView.h"
#import "OTFeedItemInfoView.h"
#import "OTTourJoinRequestViewController.h"

// Models
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTOrganization.h"
#import "OTTourJoiner.h"
#import "OTEncounter.h"
#import "OTTourMessage.h"
#import "OTTourStatus.h"
#import "OTUser.h"

// Services
#import "OTTourService.h"
#import "OTEntourageService.h"

// Helpers
#import "UIColor+entourage.h"
#import "NSUserDefaults+OT.h"
#import "IQKeyboardManager.h"
#import "UIButton+entourage.h"

#define IS_ACCEPTED ([self.feedItem.joinStatus isEqualToString:@"accepted"])

#define TAG_ORGANIZATION 1
#define TAG_TOURTYPE 2
#define TAG_TOURUSER 3

#define PADDING 10

typedef NS_ENUM(unsigned) {
    SectionTypeTimeline,
    SectionTypeHeader
    
} SectionType;



@interface OTFeedItemViewController () <UITextViewDelegate, OTTourDetailsOptionsDelegate, OTFeedItemSummaryDelegate, OTTourJoinRequestDelegate, OTFeedItemInfoDelegate>

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
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *recordButtonWidthConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *recordButtonDynamicWidthConstraint;

@property (nonatomic, strong) NSMutableArray *timelinePoints;
@property (nonatomic, strong) NSDictionary *timelineCardsClassesCellsIDs;

@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic) BOOL isRecording;

@end

@implementation OTFeedItemViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isRecording = NO;
    
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
    [self updateRecordButton];
    
    [OTSpeechKitManager setup];
    
    if ([self.feedItem isKindOfClass:[OTTour class]]) {
        [self getTourUsersJoins];
        [self getTourMessages];
        [self getTourEncounters];
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
    
    self.chatToolbar.hidden = ![self.feedItem isKindOfClass:[OTTour class]];
}

- (IBAction)showInfo {
    self.timelineView.hidden = YES;
    self.infoView.hidden = NO;
    [self.timelineButton setSelected:NO];
    [self.infoButton setSelected:YES];
    
    self.chatToolbar.hidden = YES;
    
    
    [self.infoView setupWithFeedItem:self.feedItem];
}




- (IBAction)startStopRecording:(id)sender {
    
    if (self.chatTextView.text.length) {
        [self sendMessage];
    } else {
        [self.recordButton setEnabled:NO];
        if (!self.isRecording) {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    // Microphone enabled code
                    _recognizer = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType
                                                           detection:SKShortEndOfSpeechDetection
                                                            language:@"fra-FRA"
                                                            delegate:self];
                }
                else {
                    // Microphone disabled code
                    NSLog(@"Mic not enabled!");
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"microphoneNotEnabled", nil)
                                                message:NSLocalizedString(@"promptForMicrophone", nil)
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
            }];
        } else {
            [_recognizer stopRecording];
        }
    }
}

/**************************************************************************************************/
#pragma mark - Voice recognition methods

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results {
    NSLog(@"%@", @"Finish with results");
    if (results.results.count != 0) {
        self.chatTextView.textColor = [UIColor blackColor];
        NSString *text = self.chatTextView.text;
        NSString *result = [results.results objectAtIndex:0];
        if (text.length == 0) {
            [self.chatTextView setText:result];
        } else {
            [self.chatTextView setText:[NSString stringWithFormat:@"%@ %@", text, [result lowercaseString]]];
        }
    }
    [self updateRecordButton];
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion {
    NSLog( @"Finish with error %@. Suggestion: %@", error.description, suggestion);
    [self updateRecordButton];
}

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer {
    NSLog(@"%@", @"Begin recording");
    [self.recordButton setEnabled:YES];
    self.isRecording = YES;
    [self updateRecordButton];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer {
    NSLog(@"%@", @"Finish recording");
   
    [self.recordButton setEnabled:YES];
    self.isRecording = NO;
    [self updateRecordButton];
}

/**************************************************************************************************/
#pragma mark - Private Methods

- (void)initializeTimelinePoints {
    self.timelinePoints = [[NSMutableArray alloc] init];
    
    OTTourStatus *tourStartStatus = [[OTTourStatus alloc] init];
    tourStartStatus.date = self.feedItem.creationDate;
    tourStartStatus.type = OTTourStatusStart;
    tourStartStatus.status = [NSString stringWithFormat: @"%@ en cours", self.feedItem.navigationTitle.capitalizedString];
    tourStartStatus.duration = 0;
    tourStartStatus.distance = 0;
    //[self.timelinePoints addObject:tourStartStatus];
    [self updateTableViewAddingTimelinePoints:@[tourStartStatus]];
    
    
    if ([self.feedItem isKindOfClass:[OTTour class]]) {
        OTTour *tour = (OTTour*)self.feedItem;
        
        if (tour.endTime) {
            OTTourStatus *tourEndStatus = [[OTTourStatus alloc] init];
            tourEndStatus.date = tour.endTime;
            tourStartStatus.type = OTTourStatusEnd;
            tourEndStatus.status = @"Maraude terminée";
            tourEndStatus.duration = [tour.endTime timeIntervalSinceDate:tour.creationDate];;
            tourEndStatus.distance = tour.distance.doubleValue;
            [self updateTableViewAddingTimelinePoints:@[tourEndStatus]];
        }
    }
}

- (void)setupMoreButtons {
    
    if (IS_ACCEPTED) {
    
    UIImage *plusImage = [[UIImage imageNamed:@"userPlus.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] init];
    [plusButton setImage:plusImage];
    [plusButton setTarget:self];
    //[plusButton setAction:@selector(addUser)];

    
    
    if ([self.feedItem.status isEqualToString:TOUR_STATUS_FREEZED])
        return;
    UIImage *moreImage = [[UIImage imageNamed:@"more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] init];
    [moreButton setImage:moreImage];
    [moreButton setTarget:self];
    [moreButton setAction:@selector(showOptions)];
    
    [self.navigationItem setRightBarButtonItems:@[moreButton]];
    //[self.navigationItem setRightBarButtonItem:moreButton];
    } else {
        UIImage *shareImage = [[UIImage imageNamed:@"share.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIBarButtonItem *joinButton = [[UIBarButtonItem alloc] init];
        [joinButton setImage:shareImage];
        [joinButton setTarget:self];
        [joinButton setAction:@selector(doJoinTour)];
        [self.navigationItem setRightBarButtonItem:joinButton];
    }
}

- (void)showOptions {
    [self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
}

- (void)doJoinTour {
    [self performSegueWithIdentifier:@"PublicJoinRequestSegue" sender:self];
}

- (void)updateTableViewAddingTimelinePoints:(NSArray *)timelinePoints {
    [self.timelinePoints addObjectsFromArray:timelinePoints];
    self.timelinePoints = [self.timelinePoints sortedArrayUsingSelector:@selector(compare:)].mutableCopy;
    //NSLog(@"%lu timeline points", (unsigned long)self.timelinePoints.count);
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
                                 // NSLog(@"ENCOUNTERS: %@", tourEncounters);
                                  [self updateTableViewAddingTimelinePoints:tourEncounters];
                              } failure:^(NSError *error) {
                                  NSLog(@"ENCOUNTERSSerr %@", error.description);
                              }];
}

- (IBAction)sendMessage {
    
    [self.chatTextView resignFirstResponder];
    if ([self.feedItem isKindOfClass:[OTTour class]]) {
        OTTour *tour = (OTTour *)self.feedItem;
        [[OTTourService new] sendMessage:self.chatTextView.text
                                  onTour:tour
                                 success:^(OTTourMessage * message) {
                                     NSLog(@"CHAT %@", message.text);
                                     self.chatTextView.text = @"";
                                     [self updateTableViewAddingTimelinePoints:@[message]];
                                     [self updateRecordButton];
                                 } failure:^(NSError *error) {
                                     NSLog(@"CHATerr: %@", error.description);
                                 }];
    } else {
        OTEntourage *entourage = (OTEntourage *)self.feedItem;
        [[OTEntourageService new] sendMessage:self.chatTextView.text
                                  onEntourage:entourage
                                 success:^(OTTourMessage * message) {
                                     NSLog(@"CHAT %@", message.text);
                                     self.chatTextView.text = @"";
                                     [self updateTableViewAddingTimelinePoints:@[message]];
                                     [self updateRecordButton];
                                 } failure:^(NSError *error) {
                                     NSLog(@"CHATerr: %@", error.description);
                                 }];

    }
}

- (void)updateRecordButton {
    if (self.isRecording) {
        [self.recordButton setImage:[UIImage imageNamed:@"ic_action_stop_sound.png"] forState:UIControlStateNormal];
        [self.recordButton setTitle:nil forState:UIControlStateNormal];
        self.recordButtonWidthConstraint.active = YES;
        self.recordButtonDynamicWidthConstraint.active = NO;
    } else {
        if (self.chatTextView.text.length) {
            [self.recordButton setImage:nil forState:UIControlStateNormal];
            [self.recordButton setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
            self.recordButtonWidthConstraint.active = NO;
            self.recordButtonDynamicWidthConstraint.active = YES;
        } else {
            [self.recordButton setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
            [self.recordButton setTitle:nil forState:UIControlStateNormal];
            self.recordButtonWidthConstraint.active = YES;
            self.recordButtonDynamicWidthConstraint.active = NO;
        }
    }
    [self.recordButton layoutIfNeeded];
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
#pragma mark - OTTourDetailsOptionsDelegate

- (void)promptToCloseTour {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate promptToCloseTour];
    }];
}

/**************************************************************************************************/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timelinePoints.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case SectionTypeHeader:
//            return 15.0f;
//        case SectionTypeTimeline:
//            return 40.0f;
//            
//        default:
//            return 0.0f;
//    }
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
//    if (section == SectionTypeTimeline) {
//        headerView.backgroundColor = [UIColor appPaleGreyColor];
//        headerView.text = @"DISCUSSION";
//        headerView.textAlignment = NSTextAlignmentCenter;
//        headerView.textColor = [UIColor appGreyishBrownColor];
//        headerView.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
//    }
//    return headerView;
//}

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
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"et %@ se sont rencontrés ici.", encounter.streetPersonName] attributes:lightAttrs];
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
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:@"a rejoint la maraude." attributes:lightAttrs];
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

- (void)setupHeaderCell:(UITableViewCell *)cell {
//    OTTourAuthor *author = self.tour.author;
//    UILabel *organizationLabel = [cell viewWithTag:TAG_ORGANIZATION];
//    organizationLabel.text = self.tour.organizationName;
//    
//    
//    NSString *tourType = self.tour.type;
//    if ([tourType isEqualToString:@"barehands"]) {
//        tourType = @"sociale";
//    } else     if ([tourType isEqualToString:@"medical"]) {
//        tourType = @"médicale";
//    } else if ([tourType isEqualToString:@"alimentary"]) {
//        tourType = @"distributive";
//    }
//    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightLight]};
//    NSDictionary *boldAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold]};
//    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Mauraude %@ par ", tourType] attributes:lightAttrs];
//    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:author.displayName attributes:boldAttrs];
//    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
//    [typeByNameAttrString appendAttributedString:nameAttrString];
//    UILabel *typeByNameLabel = [cell viewWithTag:TAG_TOURTYPE];
//    typeByNameLabel.attributedText = typeByNameAttrString;
//    
//    
//    UIButton *userImageButton = [cell viewWithTag:TAG_TOURUSER];
//    [userImageButton setupAsProfilePictureFromUrl:self.tour.author.avatarUrl];
//    [userImageButton addTarget:self action:@selector(doShowProfile:) forControlEvents:UIControlEventTouchUpInside];
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
            if ([timelinePoint isKindOfClass:[OTTourMessage class]])
                 return 2*PADDING + [self messageHeightForText:((OTTourMessage*)timelinePoint).text];
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
    [self updateRecordButton];
    
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
        OTTourDetailsOptionsViewController *controller = (OTTourDetailsOptionsViewController *)segue.destinationViewController;
        ///controller.tour = self.feedItem;
        controller.view.backgroundColor = [UIColor appModalBackgroundColor];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.delegate  = self;
    }
    if ([segue.identifier isEqualToString:@"OTUserProfileSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTUserViewController *controller = (OTUserViewController*)navController.topViewController;
        controller.userId = (NSNumber *)sender;
    }
    if ([segue.identifier isEqualToString:@"PublicJoinRequestSegue"]) {
        OTTourJoinRequestViewController *controller = (OTTourJoinRequestViewController *)segue.destinationViewController;
        controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.feedItem = self.feedItem;
        controller.tourJoinRequestDelegate = self;
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
