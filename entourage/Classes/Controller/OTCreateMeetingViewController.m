//
//  OTCreateMeetingViewController.m
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTCreateMeetingViewController.h"
#import "OTMainViewController.h"

// Model
#import "OTEncounter.h"
#import "OTUser.h"
#import "OTConsts.h"

// Services
#import "OTPoiService.h"
#import "OTEncounterService.h"

// Helpers
#import "NSUserDefaults+OT.h"
#import "UITextField+indentation.h"
#import "UIViewController+menu.h"
#import "UIColor+entourage.h"
#import "UIBarButtonItem+factory.h"

// Progress HUD
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"

// Frameworks
#import <Social/Social.h>
#import "OTSpeechBehavior.h"
#import "OTEncounterDisclaimerBehavior.h"


#define PADDING 20.0f
#define PLACEHOLDER OTLocalizedString(@"detailEncounter")

@interface OTCreateMeetingViewController () <UITextViewDelegate>

@property (strong, nonatomic) NSNumber *currentTourId;
@property (strong, nonatomic) NSString *lmPath;
@property (strong, nonatomic) NSString *dicPath;
@property (nonatomic) CLLocationCoordinate2D location;

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recordingLoader;
@property (strong, nonatomic) IBOutlet OTSpeechBehavior *speechBehavior;
@property (strong, nonatomic) IBOutlet OTEncounterDisclaimerBehavior *disclaimer;

@property (nonatomic) BOOL isRecording;

@end

@implementation OTCreateMeetingViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = OTLocalizedString(@"descriptionTitle").uppercaseString;
    self.isRecording = NO;
    [self setupUI];
    [self.speechBehavior initialize];
    [self.disclaimer showDisclaimer];
}

#pragma mark - Private methods

- (void)setupUI {
    [self setupCloseModal];
    
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate") withTarget:self andAction:@selector(sendEncounter:) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
    
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    self.firstLabel.text = [NSString stringWithFormat:OTLocalizedString(@"formater_encounterAnd"), currentUser.displayName];
    
    [self.nameTextField indentWithPadding:PADDING];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    self.dateLabel.text = [NSString stringWithFormat:OTLocalizedString(@"formater_meetEncounter"), dateString];
    [self.messageTextView setTextContainerInset:UIEdgeInsetsMake(PADDING, PADDING, PADDING, 2*PADDING)];
    
    self.messageTextView.text = PLACEHOLDER;
    self.messageTextView.textColor = [UIColor lightGrayColor];
}

- (void)configureWithTourId:(NSNumber *)currentTourId andLocation:(CLLocationCoordinate2D)location {
    self.currentTourId = currentTourId;
	self.location = location;
}

- (IBAction)sendEncounter:(UIBarButtonItem*)sender {
    sender.enabled = NO;
    __block OTEncounter *encounter = [OTEncounter new];
    encounter.date = [NSDate date];
    encounter.message = [self.messageTextView.text isEqualToString:PLACEHOLDER] ? @"" : self.messageTextView.text;
    encounter.streetPersonName =  self.nameTextField.text;
    encounter.latitude = self.location.latitude;
    encounter.longitude = self.location.longitude;
    [SVProgressHUD show];
    [[OTEncounterService new] sendEncounter:encounter withTourId:self.currentTourId withSuccess:^(OTEncounter *sentEncounter) {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"meetingCreated")];
        [self.encounters addObject:encounter];
        [self.delegate encounterSent:encounter];
    }
    failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"meetingNotCreated")];
        sender.enabled = YES;
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:PLACEHOLDER]) {
        self.messageTextView.text = @"";
        self.messageTextView.textColor = [UIColor blackColor];
    }
    [self.messageTextView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.messageTextView.text isEqualToString:@""]) {
        self.messageTextView.text = PLACEHOLDER;
        self.messageTextView.textColor = [UIColor appGreyishColor];
    }
    [self.messageTextView resignFirstResponder];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.disclaimer prepareSegue:segue])
        return;
}

@end
