//
//  OTCreateMeetingViewController.m
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTCreateMeetingViewController.h"
#import "OTMapViewController.h"

// Model
#import "OTEncounter.h"
#import "OTUser.h"

// Services
#import "OTPoiService.h"
#import "OTEncounterService.h"
#import "NSUserDefaults+OT.h"

// Progress HUD
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"

// Frameworks
#import <Social/Social.h>

@interface OTCreateMeetingViewController ()

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

/**************************************************************************************************/
#pragma mark - Constants

const unsigned char SpeechKitApplicationKey[] = {0x7c, 0x35, 0xab, 0xb0, 0x7e, 0x90, 0xd0, 0x74, 0x12, 0x80, 0xa8, 0x1e, 0xc0, 0xf7, 0x41, 0xda, 0x26, 0x8a, 0x81, 0x51, 0x58, 0x2b, 0xa3, 0x2d, 0x14, 0x7d, 0x14, 0x49, 0x57, 0xe7, 0x59, 0xd4, 0x1c, 0x04, 0x84, 0x9a, 0x94, 0x54, 0x0f, 0xa6, 0xd5, 0xb7, 0xc5, 0x95, 0xaf, 0x06, 0x6f, 0xd5, 0x90, 0xf1, 0x26, 0xe9, 0x1c, 0xc9, 0x16, 0x30, 0x47, 0x2a, 0x79, 0x9e, 0x12, 0xd2, 0x72, 0x2e};

@implementation OTCreateMeetingViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
	OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
	self.firstLabel.text = [NSString stringWithFormat:@"%@ et", currentUser.firstName];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd/MM/yyyy"];

	NSString *dateString = [formatter stringFromDate:[NSDate date]];

	self.dateLabel.text = [NSString stringWithFormat:@"se sont rencontrés ici le %@", dateString];

	self.messageTextView.layer.borderWidth = 1;
	self.messageTextView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    
    self.isRecording = NO;
    
    [self createSendButton];
    [self setupSpeechKitConnection];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)createSendButton {
	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    [menuButton setTarget:self];
	[menuButton setTitle:NSLocalizedString(@"button_validate", @"")];
	[menuButton setAction:@selector(sendEncounter:)];
	[self.navigationItem setRightBarButtonItem:menuButton];
}

- (void)configureWithTourId:(NSNumber *)currentTourId andLocation:(CLLocationCoordinate2D)location {
    self.currentTourId = currentTourId;
	self.location = location;
}

- (void)sendEncounter:(id)sender {
    [self postEncounterWithCompletionBlock:^(OTEncounter *encounter){
        [self.encounters addObject:encounter];
        [self.delegate encounterSent:encounter];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)postEncounterWithCompletionBlock:(void (^)(OTEncounter *))success {
	OTEncounter *encounter = [OTEncounter new];
	encounter.date = [NSDate date];
	encounter.message = self.messageTextView.text;
	encounter.streetPersonName =  self.nameTextField.text;
	encounter.latitude = self.location.latitude;
	encounter.longitude = self.location.longitude;
    
    [SVProgressHUD show];
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
    [SpeechKit setupWithID:@"NMDPTRIAL_ntelera_octo_com20151207110952"
                      host:@"sandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:NO
                  delegate:nil];
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results {
    NSLog(@"%@", @"Finish with results");
    if (results.results.count != 0) {
        NSString *text = self.messageTextView.text;
        NSString *result = [results.results objectAtIndex:0];
        if (text.length == 0) {
            [self.messageTextView setText:result];
        } else {
            [self.messageTextView setText:[NSString stringWithFormat:@"%@ %@", text, [result lowercaseString]]];
        }
    }
    
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion {
    NSLog(@"%@", @"Finish with error");
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
    [self.recordButton setImage:[UIImage imageNamed:@"ic_action_record_sound.png"] forState:UIControlStateNormal];
    [self.recordButton setEnabled:YES];
    self.isRecording = NO;
    [self.recordLabel setText:@"Appuyez pour dicter un message"];
    [self.recordingLoader setHidden:YES];
}

@end
