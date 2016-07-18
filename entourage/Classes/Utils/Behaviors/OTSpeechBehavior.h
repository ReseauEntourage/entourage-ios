//
//  OTSpeechBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#include <SpeechKit/SpeechKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface OTSpeechBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIButton *btnRecord;
@property (nonatomic, weak) IBOutlet UITextView *txtOutput;
@property (nonatomic, strong) SKRecognizer *speechRecognizer;

@end
