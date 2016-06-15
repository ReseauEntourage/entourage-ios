//
//  OTCreateMeetingViewController.m
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTCreateMeetingViewController.h"
#import "OTMainViewController.h"
#import "OTDisclaimerViewController.h"

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

// Progress HUD
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"

// Frameworks
#import <Social/Social.h>


#define PADDING 20.0f
#define PLACEHOLDER OTLocalizedString(@"detailEncounter")

@interface OTCreateMeetingViewController () <UITextViewDelegate, DisclaimerDelegate>

@property (strong, nonatomic) NSNumber *currentTourId;
@property (strong, nonatomic) NSString *lmPath;
@property (strong, nonatomic) NSString *dicPath;
@property (nonatomic) CLLocationCoordinate2D location;

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recordingLoader;

@property (nonatomic) BOOL isRecording;

@end

@implementation OTCreateMeetingViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"descriptionTitle").uppercaseString;
    
    
    self.isRecording = NO;
    
    [self setupUI];
    
    [OTSpeechKitManager setup];
    
    if (![NSUserDefaults wasDisclaimerAccepted])
        [self performSegueWithIdentifier:@"DisclaimerSegue" sender:self];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)setupUI {
    [self setupCloseModal];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:OTLocalizedString(@"validate")
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(sendEncounter:)];
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

- (IBAction)sendEncounter:(UIButton*)sender {
    sender.enabled = NO;
    [SVProgressHUD show];
    __block OTEncounter *encounter = [OTEncounter new];
    encounter.date = [NSDate date];
    encounter.message = [self.messageTextView.text isEqualToString:PLACEHOLDER] ? @"" : self.messageTextView.text;
    encounter.streetPersonName =  self.nameTextField.text;
    encounter.latitude = self.location.latitude;
    encounter.longitude = self.location.longitude;
    [[OTEncounterService new] sendEncounter:encounter withTourId:self.currentTourId
                                withSuccess:^(OTEncounter *sentEncounter) {
                                    [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"meetingCreated")];
                                    [self.encounters addObject:encounter];
                                    [self.delegate encounterSent:encounter];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                                failure:^(NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"meetingNotCreated")];
                                    sender.enabled = YES;
                                }];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)startStopRecording:(id)sender {
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
                NSLog(@"Mic not enabled!!!!");

                [[[UIAlertView alloc] initWithTitle:OTLocalizedString(@"microphoneNotEnabled")
                                            message:OTLocalizedString(@"promptForMicrophone")
                                           delegate:nil
                                  cancelButtonTitle:OTLocalizedString(@"closeAlert")
                                  otherButtonTitles:nil] show];
            }
        }];
    } else {
        [_recognizer stopRecording];
    }
}

/**************************************************************************************************/
#pragma mark - Voice recognition methods

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results {
    NSLog(@"%@", @"Finish with results");
    if (results.results.count != 0) {
        self.messageTextView.textColor = [UIColor blackColor];
        NSString *text = [self.messageTextView.text isEqualToString:PLACEHOLDER]? @"" : self.messageTextView.text;
        NSString *result = [results.results objectAtIndex:0];
        if (text.length == 0) {
            [self.messageTextView setText:result];
        } else {
            [self.messageTextView setText:[NSString stringWithFormat:@"%@ %@", text, [result lowercaseString]]];
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
    [self.recordLabel setText:@"Enregistrement..."];
    [self.recordingLoader setHidden:NO];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer {
    NSLog(@"%@", @"Finish recording");
    [self.recordButton setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    [self.recordButton setEnabled:YES];
    self.isRecording = NO;
    [self.recordLabel setText:@"Appuyez pour dicter un message"];
    [self.recordingLoader setHidden:YES];
}

/**************************************************************************************************/
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

/**************************************************************************************************/
#pragma mark - DisclaimerDelegate
- (void)disclaimerWasAccepted {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDisclaimer];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)disclaimerWasRejected {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDisclaimer];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

/**************************************************************************************************/

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UINavigationController *navigationViewController = segue.destinationViewController;
    UIViewController *destinationViewController = navigationViewController.topViewController;
    if ([destinationViewController isKindOfClass:[OTDisclaimerViewController class]]) {
        ((OTDisclaimerViewController*)destinationViewController).disclaimerDelegate = self;
    }
}

@end
