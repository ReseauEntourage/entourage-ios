//
//  OTAudioButton.h
//  entourage
//
//  Created by Hugo Schouman on 28/01/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	RecordingButtonStateInit = 0,   // display record
	RecordingButtonStateRecording, // display stop
	RecordingButtonStateRecorded, // display play
    RecordingButtonStatePlaying, // display pause
    RecordingButtonStatePaused, // display play
    RecordingButtonStatePlayed // display play
} RecordingButtonState;

@interface OTAudioButton : UIButton


@property (nonatomic) RecordingButtonState recordingState;

@end
