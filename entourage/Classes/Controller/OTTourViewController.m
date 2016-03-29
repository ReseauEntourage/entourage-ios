//
//  OTTourViewController.m
//  entourage
//
//  Created by Nicolas Telera on 20/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTTourViewController.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTOrganization.h"
#import "UIViewController+menu.h"
#import "UIColor+entourage.h"
#import "OTTourDetailsOptionsViewController.h"
#import "OTTourService.h"
#import "NSUserDefaults+OT.h"

#import "OTTourJoiner.h"
#import "OTEncounter.h"
#import "OTTourMessage.h"
#import "OTTourStatus.h"
#import "IQKeyboardManager.h"
#import "OTUser.h"
#import "UIButton+entourage.h"



#define TAG_ORGANIZATION 1
#define TAG_TOURTYPE 2
#define TAG_TOURUSER 3

#define PADDING 10

typedef NS_ENUM(unsigned) {
    SectionTypeHeader,
    SectionTypeTimeline
} SectionType;

/**************************************************************************************************/
#pragma mark - Constants

//const unsigned char SpeechKitApplicationKey[] = {0x7f, 0x91, 0xf8, 0xff, 0x2e, 0xc2, 0xcd, 0x4a, 0x31, 0x70, 0x9f, 0x4a, 0x34, 0x5d, 0x4c, 0xc0, 0x2c, 0xc1, 0xce, 0x26, 0xda, 0xdb, 0xd7, 0x3b, 0x28, 0x9c, 0x58, 0x0c, 0xb8, 0xc7, 0x4a, 0x37, 0x58, 0x42, 0x36, 0x86, 0x04, 0x03, 0xd1, 0x35, 0x74, 0x70, 0x80, 0xa8, 0xcd, 0xcc, 0x69, 0xfa, 0x8e, 0x37, 0x20, 0x68, 0x12, 0xf7, 0xa4, 0x3a, 0x94, 0xfc, 0x47, 0x4c, 0xc3, 0x91, 0x83, 0x1c};

@interface OTTourViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextView *chatTextView;
@property (nonatomic, weak) IBOutlet UIView *chatToolbar;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *chatHConstraint;

@property (nonatomic, strong) NSMutableArray *timelinePoints;
@property (nonatomic, strong) NSDictionary *timelineCardsClassesCellsIDs;

@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic) BOOL isRecording;

@end

@implementation OTTourViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MARAUDE";
    [self setupCloseModal];
    [self setupMoreButtons];
    
    self.timelineCardsClassesCellsIDs = @{@"OTTourJoiner": @"TourJoinerCell",
                                          @"OTTourMessage": @"TourMessageCell",
                                          @"OTEncounter": @"TourEncounterCell",
                                          @"OTTourStatus": @"TourStatusCell"};
    
    [self initializeTimelinePoints];
    
    [self getTourUsersJoins];
    [self getTourMessages];
    [self getTourEncounters];
    
    
    self.chatTextView.layer.borderColor = [UIColor appGreyishColor].CGColor;
    //[self.chatTextView setInputAccessoryView:self.chatToolbar];
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
    
    self.isRecording = NO;
    [self setupSpeechKitConnection];
    
}
/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)startStopRecording:(id)sender {
    [self.recordButton setEnabled:NO];
    
    if (!self.isRecording) {
        _recognizer = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType
                                               detection:SKShortEndOfSpeechDetection
                                                language:@"fra-FRA"
                                                delegate:self];
    } else {
        [_recognizer stopRecording];
    }
}

/**************************************************************************************************/
#pragma mark - Voice recognition methods

- (void)setupSpeechKitConnection {
    [SpeechKit setupWithID:@"NMDPPRODUCTION_Fran__ois_Pellissier_Entourage_20160104053924"
                      host:@"gcb.nmdp.nuancemobility.net"
                      port:443
                    useSSL:YES
                  delegate:nil];
}

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
    
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion {
    NSLog( @"Finish with error %@. Suggestion: %@", error.description, suggestion);
}

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer {
    NSLog(@"%@", @"Begin recording");
    [self.recordButton setImage:[UIImage imageNamed:@"ic_action_stop_sound.png"] forState:UIControlStateNormal];
    [self.recordButton setEnabled:YES];
    self.isRecording = YES;
    //[self.recordLabel setText:@"Enregistrement..."];
    //[self.recordingLoader setHidden:NO];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer {
    NSLog(@"%@", @"Finish recording");
    [self.recordButton setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    [self.recordButton setEnabled:YES];
    self.isRecording = NO;
    //[self.recordLabel setText:@"Appuyez pour dicter un message"];
    //[self.recordingLoader setHidden:YES];
}


/**************************************************************************************************/
#pragma mark - Private Methods

- (void)initializeTimelinePoints {
    self.timelinePoints = [[NSMutableArray alloc] init];
    
    OTTourStatus *tourStartStatus = [[OTTourStatus alloc] init];
    tourStartStatus.date = self.tour.startTime;
    tourStartStatus.status = @"Maraude en cours";
    tourStartStatus.duration = 0;
    tourStartStatus.km = 0;
    //[self.timelinePoints addObject:tourStartStatus];
    [self updateTableViewAddingTimelinePoints:@[tourStartStatus]];
    
    if (self.tour.endTime) {
        OTTourStatus *tourEndStatus = [[OTTourStatus alloc] init];
        tourEndStatus.date = self.tour.endTime;
        tourEndStatus.status = @"Maraude terminée";
        tourEndStatus.duration = [self.tour.endTime timeIntervalSinceDate:self.tour.startTime];;
        tourEndStatus.km = self.tour.distance;
        //[self.timelinePoints addObject:tourStartStatus];
        [self updateTableViewAddingTimelinePoints:@[tourEndStatus]];
    }
}

- (void)setupMoreButtons {
    UIImage *plusImage = [[UIImage imageNamed:@"userPlus.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] init];
    [plusButton setImage:plusImage];
    [plusButton setTarget:self];
    //[plusButton setAction:@selector(addUser)];

    
    UIImage *moreImage = [[UIImage imageNamed:@"more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] init];
    [moreButton setImage:moreImage];
    [moreButton setTarget:self];
    [moreButton setAction:@selector(showOptions)];
    
    [self.navigationItem setRightBarButtonItems:@[moreButton]];
    //[self.navigationItem setRightBarButtonItem:moreButton];
}

- (void)showOptions {
    [self performSegueWithIdentifier:@"TourOptionsSegue" sender:nil];
}

- (void)updateTableViewAddingTimelinePoints:(NSArray *)timelinePoints {
    [self.timelinePoints addObjectsFromArray:timelinePoints];
    self.timelinePoints = [self.timelinePoints sortedArrayUsingSelector:@selector(compare:)].mutableCopy;
    NSLog(@"%lu timeline points", (unsigned long)self.timelinePoints.count);
    [self.tableView reloadData];
    
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.timelinePoints.count-1 inSection:1];
     [self.tableView scrollToRowAtIndexPath:indexPath
                           atScrollPosition:UITableViewScrollPositionBottom
                                   animated:YES];

}


#pragma mark - Service
- (void)getTourUsersJoins {
    [[OTTourService new] tourUsersJoins:self.tour
                                success:^(NSArray *tourUsers) {
                                    NSLog(@"USERS: %@", tourUsers);
                                    [self updateTableViewAddingTimelinePoints:tourUsers];
    } failure:^(NSError *error) {
        NSLog(@"USERSerr %@", error.description);
    }];
}

- (void)getTourMessages {
    [[OTTourService new] tourMessages:self.tour
                                success:^(NSArray *tourMessages) {
                                    NSLog(@"MESSAGES: %@", tourMessages);
                                    [self updateTableViewAddingTimelinePoints:tourMessages];

    } failure:^(NSError *error) {
        NSLog(@"MESSAGESerr %@", error.description);
    }];
}

- (void)getTourEncounters {
    [[OTTourService new] tourEncounters:self.tour
                              success:^(NSArray *tourEncounters) {
                                  NSLog(@"ENCOUNTERS: %@", tourEncounters);
                                  [self updateTableViewAddingTimelinePoints:tourEncounters];
                              } failure:^(NSError *error) {
                                  NSLog(@"ENCOUNTERSSerr %@", error.description);
                              }];
}

- (IBAction)sendMessage {
    
    [self.chatTextView resignFirstResponder];
    
    [[OTTourService new] sendMessage:self.chatTextView.text
                              onTour:self.tour
                             success:^(OTTourMessage * message) {
                                 NSLog(@"CHAT %@", message.text);
                                 self.chatTextView.text = @"";
                                 [self updateTableViewAddingTimelinePoints:@[message]];
                             } failure:^(NSError *error) {
                                 NSLog(@"CHATerr: %@", error.description);
                             }];
}

/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithTour:(OTTour *)tour {
    self.tour = tour;
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
    [formatter setDateFormat:@"HH':'mm':'ss"];
    return [formatter stringFromDate:date];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**************************************************************************************************/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionTypeHeader:
            return 1;
        case SectionTypeTimeline:{
            NSLog(@"tPoints %lu", (unsigned long)self.timelinePoints.count);
            return self.timelinePoints.count;
        }
            
        default:
            return 0.0f;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SectionTypeHeader:
            return 15.0f;
        case SectionTypeTimeline:
            return 40.0f;
            
        default:
            return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    if (section == SectionTypeTimeline) {
        headerView.backgroundColor = [UIColor appPaleGreyColor];
        headerView.text = @"DISCUSSION";
        headerView.textAlignment = NSTextAlignmentCenter;
        headerView.textColor = [UIColor appGreyishBrownColor];
        headerView.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"";
    switch (indexPath.section) {
        case SectionTypeHeader:
            cellID = @"TourDetailsCell";
            break;
        case SectionTypeTimeline: {
            NSString *timelinePointClassName = NSStringFromClass([ self.timelinePoints[indexPath.row] class]);
            cellID = [self.timelineCardsClassesCellsIDs valueForKey:timelinePointClassName];
        }
            break;
        default:
            break;
    }

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if (indexPath.section == SectionTypeHeader) {
        [self setupHeaderCell:cell];
    } else {
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
    }
    return cell;
}

#define TIMELINE_TIME_TAG 10
#define TIMELINE_STATUS_TAG 11
#define TIMELINE_DURATION_TAG 12
#define TIMELINE_KM_TAG 13

#define TIMELINE_MESSAGE_TAG 30
#define TIMELINE_MESSAGE_USER 31
#define TIMELINE_MESSAGE_TEXT 32

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
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:@"a rejoint votre maraude." attributes:lightAttrs];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    UILabel *joinerLabel = [cell viewWithTag:TIMELINE_JOINER];
    joinerLabel.attributedText = typeByNameAttrString;
}

- (void)setupMessageCell:(UITableViewCell *)cell withMessage:(OTTourMessage *)message {
    
    UIView *messageContainer = [cell viewWithTag:TIMELINE_MESSAGE_TAG];
    CGFloat height = [self messageHeightForText:message.text];
    
    messageContainer.layer.cornerRadius = 5;
    messageContainer.clipsToBounds = YES;

    for (NSLayoutConstraint *constraint in messageContainer.constraints) {
        if ([constraint.identifier isEqualToString:@"chatHeight"]) {
            constraint.constant = height;
        }
        //NSLog(@"constraint %@", constraint.identifier);
        OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
        if ([currentUser.sid intValue] == [message.uID intValue]) {
            if ([constraint.identifier isEqualToString:@"chatLeading"]) {
                CGFloat leading = [UIScreen mainScreen].bounds.size.width - messageContainer.bounds.size.width;
                constraint.constant = leading;
            }
        }
    }
    //user
    
    
    
    UIButton *userImageButton = [cell viewWithTag:TIMELINE_MESSAGE_USER];
    [userImageButton setupAsProfilePictureFromUrl:message.userAvatarURL];
    
    
    //text
    UILabel *messageLabel = [cell viewWithTag:TIMELINE_MESSAGE_TEXT];
    messageLabel.text = message.text;
    //messageLabel.textColor = [UIColor whiteColor];
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.layer.cornerRadius = 5;
    messageLabel.clipsToBounds = YES;
    [messageContainer addSubview:messageLabel];
    
}

- (void)setupStatusCell:(UITableViewCell *)cell withStatus:(OTTourStatus *)statusPoint {
    UILabel *timeLabel = [cell viewWithTag:TIMELINE_TIME_TAG];
    NSString *day  = [self formatDateForDisplay:statusPoint.date];
    NSString *time = [self formatHourForDisplay:statusPoint.date];
    
    timeLabel.text = [NSString stringWithFormat:@"%@. %@", [day uppercaseString], time];
    
    UILabel *statusLabel = [cell viewWithTag:TIMELINE_STATUS_TAG];
    statusLabel.text = statusPoint.status;
    
    UILabel *durationLabel = [cell viewWithTag:TIMELINE_DURATION_TAG];
    durationLabel.text = [self formatHourToSecondsForDisplay:[NSDate dateWithTimeIntervalSince1970: statusPoint.duration]];
    
    UILabel *kmLabel = [cell viewWithTag:TIMELINE_KM_TAG];
    kmLabel.text = [NSString stringWithFormat:@"%.2fkm", statusPoint.km];

}

- (void)setupHeaderCell:(UITableViewCell *)cell {
    OTTourAuthor *author = self.tour.author;
    UILabel *organizationLabel = [cell viewWithTag:TAG_ORGANIZATION];
    organizationLabel.text = self.tour.organizationName;
    
    
    NSString *tourType = self.tour.tourType;
    if ([tourType isEqualToString:@"barehands"]) {
        tourType = @"sociale";
    } else     if ([tourType isEqualToString:@"medical"]) {
        tourType = @"médicale";
    } else if ([tourType isEqualToString:@"alimentary"]) {
        tourType = @"distributive";
    }
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightLight]};
    NSDictionary *boldAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold]};
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Mauraude %@ par ", tourType] attributes:lightAttrs];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:author.displayName attributes:boldAttrs];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    UILabel *typeByNameLabel = [cell viewWithTag:TAG_TOURTYPE];
    typeByNameLabel.attributedText = typeByNameAttrString;
    
    
    UIButton *userImageButton = [cell viewWithTag:TAG_TOURUSER];
    [userImageButton setupAsProfilePictureFromUrl:self.tour.author.avatarUrl];

}

- (void)doShowProfile:(UIButton *)senderButton {
    
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
    CGSize maximumLabelSize = CGSizeMake(297, FLT_MAX);
    
    CGSize expectedLabelSize = [messageContent sizeWithFont:[UIFont systemFontOfSize:15 weight:UIFontWeightLight] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    return expectedLabelSize.height + 4*PADDING;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.selectedTour = self.tours[indexPath.row];
//    [self performSegueWithIdentifier:@"OTSelectedTour" sender:self];
//}

#pragma mark - UITextFieldDelegate

#define TEXTFIELD_HEIGHT_MIN 30.f

- (void)textViewDidChange:(UITextView *)textView {
    CGSize newSize = [textView.text
                      sizeWithFont:textView.font
                      constrainedToSize:CGSizeMake(224, 80)
                      lineBreakMode:NSLineBreakByWordWrapping];
    self.chatHConstraint.constant = MAX(TEXTFIELD_HEIGHT_MIN, newSize.height + PADDING);
   // NSLog(@"newsize: %f * %f", newSize.width, newSize.height);

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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    OTTourDetailsOptionsViewController *controller = (OTTourDetailsOptionsViewController *)segue.destinationViewController;
    controller.tour = self.tour;
    controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
}

@end
