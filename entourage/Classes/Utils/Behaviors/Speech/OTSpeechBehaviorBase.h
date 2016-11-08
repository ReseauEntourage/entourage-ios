//
//  OTSpeechBehaviorBase.h
//  entourage
//
//  Created by sergiu buceac on 10/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#include <SpeechKit/SpeechKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "OTSpeechKitManager.h"

@interface OTSpeechBehaviorBase : OTBehavior

@property (nonatomic, weak) IBOutlet UIButton *btnRecord;
@property (nonatomic, strong) SKRecognizer *speechRecognizer;
@property (nonatomic) BOOL twoState;
@property (nonatomic, strong) NSString *currentText;

@property (nonatomic) BOOL isRecording;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthDynamicConstraint;

- (void)updateRecordButton;
- (void)endEdit;
- (void)updateAfterSpeech;

@end
