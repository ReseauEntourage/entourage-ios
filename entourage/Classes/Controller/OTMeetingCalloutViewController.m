//
//  OTMeetingCalloutViewController.m
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTMeetingCalloutViewController.h"

// Model
#import "OTEncounter.h"

// Helper
#import "NSUserDefaults+OT.h"

// Player
#import "OTPlayerView.h"

// Service
#import "OTSoundCloudService.h"

@interface OTMeetingCalloutViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet OTPlayerView *player;


@end

@implementation OTMeetingCalloutViewController

/********************************************************************************/
#pragma mark - Public Methods

- (void)configureWithEncouter:(OTEncounter *)encounter {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

	[formatter setDateFormat:@"dd/MM/yyyy à HH:mm"];

	NSString *date = [formatter stringFromDate:encounter.date];

	NSString *title = [NSString stringWithFormat:@"%@ %@ %@ %@, le %@", encounter.userName, NSLocalizedString(@"has_encountered", @""), encounter.streetPersonName, NSLocalizedString(@"here", @""), date];

	self.titleLabel.text = title;

	NSString *body = @"";

//	if (encounter.voiceMessage.length == 0) {
//		self.player.hidden = YES;
//	}
//	else {
//		self.player.hidden = NO;
//		self.player.isRecordingMode = NO;
//	}
#warning TO BE REMOVED when back will persist url
	encounter.voiceMessage = @"https://api.soundcloud.com/tracks/188445194/stream";

	[[OTSoundCloudService new] downloadSoundAtURL:encounter.voiceMessage progress: ^(CGFloat percentageProgress) {
	    //
	} success: ^(NSData *streamData) {
	    self.player.hidden = NO;
	    self.player.isRecordingMode = NO;
	    self.player.dowloadedFile = streamData;
	} failure: ^(NSError *error) {
	    //
	}];


	if (encounter.message.length != 0) {
		body = [NSString stringWithFormat:@"%@ :\n %@", NSLocalizedString(@"their_message", @""), encounter.message];
	}

	self.textView.text = body;
}

/********************************************************************************/
#pragma mark - Private Methods

- (void)appendNotNilString:(NSString *)otherText toString:(NSMutableString *)text {
	if (otherText) {
		[text appendFormat:@"\n%@", otherText];
	}
}

/********************************************************************************/
#pragma mark - IBActions

- (IBAction)closeMe:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
