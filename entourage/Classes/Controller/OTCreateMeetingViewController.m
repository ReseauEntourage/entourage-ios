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
#define PLACEHOLDER @"Détaillez votre rencontre"

@interface OTCreateMeetingViewController () <UITextViewDelegate>

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
    self.title = @"DESCRIPTION";
    
    self.isRecording = NO;
    
    [self setupUI];
    
    [OTSpeechKitManager setup];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)setupUI {
    [self setupCloseModal];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Valider"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(sendEncounter:)];
    [self.navigationItem setRightBarButtonItem:menuButton];

    
    
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    self.firstLabel.text = [NSString stringWithFormat:@"%@ et", currentUser.displayName];
    
    [self.nameTextField indentWithPadding:PADDING];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    self.dateLabel.text = [NSString stringWithFormat:@"se sont rencontrés ici le %@", dateString];
    [self.messageTextView setTextContainerInset:UIEdgeInsetsMake(PADDING, PADDING, PADDING, 2*PADDING)];
    
    self.messageTextView.text = PLACEHOLDER;
    self.messageTextView.textColor = [UIColor lightGrayColor];

}

- (void)configureWithTourId:(NSNumber *)currentTourId andLocation:(CLLocationCoordinate2D)location {
    self.currentTourId = currentTourId;
	self.location = location;
}

- (IBAction)sendEncounter:(id)sender {
    [self postEncounterWithCompletionBlock:^(OTEncounter *encounter){
        [self.encounters addObject:encounter];
        [self.delegate encounterSent:encounter];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)postEncounterWithCompletionBlock:(void (^)(OTEncounter *))success {
    [SVProgressHUD show];
    
    OTEncounter *encounter = [OTEncounter new];
	encounter.date = [NSDate date];
    encounter.message = [self.messageTextView.text isEqualToString:PLACEHOLDER] ? @"" : self.messageTextView.text;
	encounter.streetPersonName =  self.nameTextField.text;
	encounter.latitude = self.location.latitude;
	encounter.longitude = self.location.longitude;
    
    [[OTEncounterService new] sendEncounter:encounter withTourId:self.currentTourId
                                withSuccess:^(OTEncounter *sentEncounter) {
                                    [SVProgressHUD showSuccessWithStatus:@"Rencontre créée"];
                                     if (success) {
                                         success(encounter);
                                     }
                                     else
                                     {
                                         [self.delegate encounterSent:encounter];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }
                                 } failure:^(NSError *error) {
                                     [SVProgressHUD showErrorWithStatus:@"Echec de la création de rencontre"];
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

                [[[UIAlertView alloc] initWithTitle:@"Accès refusé au micro"
                                            message:@"L'application demande l'accès à votre microphone.\n\nSVP Activez l'accès au micro pour cette app dans Réglages > Confidentialité > Micro"
                                           delegate:nil
                                  cancelButtonTitle:@"Dismiss"
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

@end
