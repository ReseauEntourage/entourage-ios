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

@interface OTMeetingCalloutViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

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

	if (encounter.message.length != 0 && encounter.voiceMessage.length == 0) {
		body = [NSString stringWithFormat:@"%@ :\n %@", NSLocalizedString(@"their_message", @""), encounter.message];
	}
	else {
		body = [NSString stringWithFormat:@"%@ :\n %@\n%@ :\n%@", NSLocalizedString(@"their_message", @""), encounter.message, NSLocalizedString(@"their_audio_message", @""), encounter.voiceMessage];
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
	if ([self.delegate respondsToSelector:@selector(dismissPopover)]) {
		[self.delegate dismissPopover];
	}
}

@end
