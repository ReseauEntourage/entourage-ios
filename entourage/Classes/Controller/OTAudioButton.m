//
//  OTAudioButton.m
//  entourage
//
//  Created by Hugo Schouman on 28/01/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import "OTAudioButton.h"



@implementation OTAudioButton


- (void)setRecordingState:(RecordingButtonState)recordingState {
	if (recordingState != _recordingState) {
		_recordingState = recordingState;
		[self configureButtonForRecordingState];
	}
}

- (void)configureButtonForRecordingState {
	NSString *imageName = @"record";

	switch (self.recordingState) {
		case RecordingButtonStateInit:
			imageName = @"record";
			break;

		case RecordingButtonStateRecording:
			imageName = @"stop";
			break;

		case RecordingButtonStateRecorded:
			imageName = @"play.png";
			break;
            
        case RecordingButtonStatePlaying:
            imageName = @"pause.png";
            break;
            
        case RecordingButtonStatePaused:
            imageName = @"play.png";
            break;
            
        case RecordingButtonStatePlayed:
            imageName = @"play.png";
            break;

		default:
			imageName = @"record";
			break;
	}

	[self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	[self setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}

@end
