//
//  OTSpeechBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSpeechBehavior.h"
#import "OTConsts.h"
#import "OTTextView.h"

@interface OTSpeechBehavior () <SKRecognizerDelegate, UITextViewDelegate>

@property (nonatomic) BOOL isRecording;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthDynamicConstraint;

@end

@implementation OTSpeechBehavior

- (id)init {
    self = [super init];
    if(self) {
        self.twoState = NO;
    }
    return self;
}

- (void)initialize {
    if(!self.txtOutput.delegate)
        self.txtOutput.delegate = self;
    
    // to be removed on 1.9
    [OTSpeechKitManager setup];
    for(NSLayoutConstraint *constraint in self.btnRecord.constraints) {
        if(constraint.firstAttribute == NSLayoutAttributeWidth && constraint.secondAttribute == NSLayoutAttributeNotAnAttribute) {
            self.widthConstraint = constraint;
            break;
        }
    }
    if(!self.widthConstraint)
        [NSException raise:@"Constraint not found" format:@"No width constraint on record button"];
    self.widthDynamicConstraint = [NSLayoutConstraint constraintWithItem:self.btnRecord attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.widthConstraint.constant];
    self.widthDynamicConstraint.active = NO;
    [self.btnRecord addConstraint:self.widthDynamicConstraint];
    self.isRecording = NO;
    [self.btnRecord addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateRecordButton {
    self.widthConstraint.active = YES;
    if (self.isRecording) {
        [self.btnRecord setImage:[UIImage imageNamed:@"ic_action_stop_sound.png"] forState:UIControlStateNormal];
        [self.btnRecord setTitle:nil forState:UIControlStateNormal];
    } else {
        [self.btnRecord setImage:nil forState:UIControlStateNormal];
        if (self.txtOutput.text.length > 0 && !self.twoState) {
            [self.btnRecord setTitle:OTLocalizedString(@"send") forState:UIControlStateNormal];
            self.widthConstraint.active = NO;
        } else
            [self.btnRecord setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    }
    self.widthDynamicConstraint.active = !self.widthConstraint.active;
    [self.btnRecord layoutIfNeeded];
}

- (void)toggleRecording {
    if (!self.twoState && self.txtOutput.text.length) {
        [self.txtOutput resignFirstResponder];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else {
        [self.btnRecord setEnabled:NO];
        if (!self.isRecording) {
            [Flurry logEvent:@"SpeechRecognitionMessage"];
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted)
                    self.speechRecognizer = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType detection:SKShortEndOfSpeechDetection language:@"fra-FRA" delegate:self];
                else
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"microphoneNotEnabled", nil) message:NSLocalizedString(@"promptForMicrophone", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
        else
            [self.speechRecognizer stopRecording];
    }
}

#pragma mark - Voice recognition methods

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results {
    if (results.results.count != 0) {
        self.txtOutput.textColor = [UIColor blackColor];
        NSString *text = self.txtOutput.text;
        NSString *result = [results.results objectAtIndex:0];
        if (text.length == 0)
            [self.txtOutput setText:result];
        else
            [self.txtOutput setText:[NSString stringWithFormat:@"%@ %@", text, [result lowercaseString]]];
        if([self.txtOutput class] == [OTTextView class])
            [((OTTextView *)self.txtOutput) updateAfterSpeech];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    [self updateRecordButton];
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion {
    [self updateRecordButton];
}

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer {
    [self.btnRecord setEnabled:YES];
    self.isRecording = YES;
    [self updateRecordButton];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer {
    [self.btnRecord setEnabled:YES];
    self.isRecording = NO;
    [self updateRecordButton];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [Flurry logEvent:@"WriteMessage"];
    [self updateRecordButton];
}

@end
