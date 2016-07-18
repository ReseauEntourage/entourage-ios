//
//  OTSpeechBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSpeechBehavior.h"
#import "OTConsts.h"

@interface OTSpeechBehavior () <SpeechKitDelegate, SKRecognizerDelegate>

@property (nonatomic) BOOL isRecording;

@end

@implementation OTSpeechBehavior

- (void)awakeFromNib {
    self.isRecording = NO;
    [self.btnRecord addTarget:self action:@selector(toggleRecording:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)toggleRecording:(id)sender {
    if (self.txtOutput.text.length) {
        //[self sendMessage];
    } else {
        [self.btnRecord setEnabled:NO];
        if (!self.isRecording)
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted)
                    // Microphone enabled code
                    _speechRecognizer = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType detection:SKShortEndOfSpeechDetection language:@"fra-FRA" delegate:self];
                else
                    // Microphone disabled code
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"microphoneNotEnabled", nil) message:NSLocalizedString(@"promptForMicrophone", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        else
            [_speechRecognizer stopRecording];
    }
}

#pragma mark - Voice recognition methods

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results {
    NSLog(@"%@", @"Finish with results");
    if (results.results.count != 0) {
        self.txtOutput.textColor = [UIColor blackColor];
        NSString *text = self.txtOutput.text;
        NSString *result = [results.results objectAtIndex:0];
        if (text.length == 0) {
            [self.txtOutput setText:result];
        } else {
            [self.txtOutput setText:[NSString stringWithFormat:@"%@ %@", text, [result lowercaseString]]];
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
    [self.btnRecord setEnabled:YES];
    self.isRecording = YES;
    [self updateRecordButton];
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer {
    NSLog(@"%@", @"Finish recording");
    [self.btnRecord setEnabled:YES];
    self.isRecording = NO;
    [self updateRecordButton];
}

#pragma mark - Private Methods

- (void)updateRecordButton {
    if (self.isRecording) {
        [self.btnRecord setImage:[UIImage imageNamed:@"ic_action_stop_sound.png"] forState:UIControlStateNormal];
        [self.btnRecord setTitle:nil forState:UIControlStateNormal];
        //self.recordButtonWidthConstraint.active = YES;
    } else {
        [self.btnRecord setImage:nil forState:UIControlStateNormal];
        if (self.txtOutput.text.length) {
            [self.btnRecord setTitle:OTLocalizedString(@"send") forState:UIControlStateNormal];
            //self.recordButtonWidthConstraint.active = NO;
        } else {
            [self.btnRecord setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
            //self.recordButtonWidthConstraint.active = YES;
        }
    }
    //self.recordButtonDynamicWidthConstraint.active = !self.recordButtonWidthConstraint.active;
    [self.btnRecord layoutIfNeeded];
}

@end
