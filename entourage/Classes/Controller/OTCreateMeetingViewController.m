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

// Social
#import <Social/Social.h>

@interface OTCreateMeetingViewController ()

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

@property (strong, nonatomic) NSNumber *currentTourId;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@end

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
        
    [self createSendButton];
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
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
    [[OTEncounterService new] sendEncounter:encounter withTourId:self.currentTourId
                                withSuccess:^(OTEncounter *sentEncounter) {
                                     if (success) {
                                         success(encounter);
                                     }
                                     else
                                     {
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }
                                 } failure:^(NSError *error) {
                                 }];
}

- (IBAction)startVoiceRecognition:(id)sender {
    if (![[OEPocketsphinxController sharedInstance] isListening]) {
        [self.recordButton setTitle:@"RECORD" forState:UIControlStateNormal];
        
        OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];

        NSString *lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"LanguageModelFiles"];;
        NSString *dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"LanguageModelFiles"];;
    
        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath
                                                                        dictionaryAtPath:dicPath
                                                                     acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]
                                                                     languageModelIsJSGF:NO];
    } else {
        [self.recordButton setTitle:@"STOP" forState:UIControlStateNormal];
        
        [[OEPocketsphinxController sharedInstance] stopListening];
        NSString *text = [[OEPocketsphinxController sharedInstance] pathToTestFile];
        NSLog(@"%@", text);
    }
}

/**************************************************************************************************/
#pragma mark - Voice Recognition methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end
