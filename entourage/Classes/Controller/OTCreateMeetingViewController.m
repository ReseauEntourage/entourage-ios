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
#import "UITextField+indentation.h"

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

const unsigned char SpeechKitApplicationKey[] = {0x7f, 0x91, 0xf8, 0xff, 0x2e, 0xc2, 0xcd, 0x4a, 0x31, 0x70, 0x9f, 0x4a, 0x34, 0x5d, 0x4c, 0xc0, 0x2c, 0xc1, 0xce, 0x26, 0xda, 0xdb, 0xd7, 0x3b, 0x28, 0x9c, 0x58, 0x0c, 0xb8, 0xc7, 0x4a, 0x37, 0x58, 0x42, 0x36, 0x86, 0x04, 0x03, 0xd1, 0x35, 0x74, 0x70, 0x80, 0xa8, 0xcd, 0xcc, 0x69, 0xfa, 0x8e, 0x37, 0x20, 0x68, 0x12, 0xf7, 0xa4, 0x3a, 0x94, 0xfc, 0x47, 0x4c, 0xc3, 0x91, 0x83, 0x1c};

@implementation OTCreateMeetingViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DECRIVEZ LA RENCONTRE";
    
	OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
	self.firstLabel.text = [NSString stringWithFormat:@"%@ et", currentUser.firstName];
    
    [self.nameTextField indent];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd/MM/yyyy"];

	NSString *dateString = [formatter stringFromDate:[NSDate date]];
	self.dateLabel.text = [NSString stringWithFormat:@"se sont rencontrés ici le %@", dateString];
    [self.messageTextView setTextContainerInset:UIEdgeInsetsMake(15, 15, 0, 0)];
	
    self.isRecording = NO;
    
    //[self createSendButton];
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

- (IBAction)sendEncounter:(id)sender {
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
    [SpeechKit setupWithID:@"NMDPPRODUCTION_Fran__ois_Pellissier_Entourage_20160104053924"
                      host:@"gcb.nmdp.nuancemobility.net"
                      port:443
                    useSSL:YES
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
