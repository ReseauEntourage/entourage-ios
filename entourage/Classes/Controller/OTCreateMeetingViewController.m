//
//  OTCreateMeetingViewController.m
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTCreateMeetingViewController.h"

// Model
#import "OTEncounter.h"

// Services
#import "OTPoiService.h"


#import "NSUserDefaults+OT.h"
#import "OTUser.h"

#import "OTPlayerView.h"
#import "OTSoundCloudService.h"


// Progress HUD
#import "MBProgressHUD.h"


@interface OTCreateMeetingViewController ()

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet OTPlayerView *playerView;

@end

@implementation OTCreateMeetingViewController

- (void)viewDidLoad {
	OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
	self.firstLabel.text = [NSString stringWithFormat:@"%@ et", currentUser.firstName];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd/MM/yyyy"];

	NSString *dateString = [formatter stringFromDate:[NSDate date]];

	self.dateLabel.text = [NSString stringWithFormat:@"se sont rencontré ici le %@", dateString];

	self.messageTextView.layer.borderWidth = 1;
	self.messageTextView.layer.borderColor = UIColor.lightGrayColor.CGColor;

	self.playerView.isRecordingMode = YES;

	[self createSendButton];
}

- (void)createSendButton {
	UIBarButtonItem *menuButton = nil;
	menuButton = [[UIBarButtonItem alloc] init];
	[menuButton setTitle:@"Valider"];
	[menuButton setAction:@selector(sendEncounter:)];
	[self.navigationItem setRightBarButtonItem:menuButton];
}

- (void)configureWithLocation:(CLLocationCoordinate2D)location {
	self.location = location;
}

- (IBAction)sendEncounter:(id)sender {
	if ([self.playerView hasRecordedFile]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"dd/MM/yyyy à HH:mm"];
		NSString *date = [formatter stringFromDate:[NSDate date]];
		NSString *title = [NSString stringWithFormat:@"%@ %@ %@, le %@", [[NSUserDefaults standardUserDefaults] currentUser].firstName, NSLocalizedString(@"has_encountered", @""), self.nameTextField.text, date];


		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
		hud.labelText = @"Audio Uploading";


		OTSoundCloudService *service = [OTSoundCloudService new];
		[service uploadSoundAtURL:self.playerView.recordedURL
		                    title:title
		                 progress: ^(CGFloat percentageProgress)
		{
		    hud.progress = percentageProgress;
		    NSLog(@"percentageProgress = %f", percentageProgress);
		}

		                  success: ^(NSString *uploadLocation)
		{
		    [hud hide:YES];
		    [self postEncounterWithAudioFile:uploadLocation];
		}

		 failure: ^(NSError *error)
		{
		    [hud hide:YES];
		    NSLog(@"error = %@", error);
		}];
	}
	else {
		[self postEncounterWithAudioFile:nil];
	}
}

- (void)postEncounterWithAudioFile:(NSString *)urlOfAudioMessage {
	OTEncounter *encounter = [OTEncounter new];
	encounter.date = [NSDate date];
	encounter.message = self.messageTextView.text;
	encounter.streetPersonName =  self.nameTextField.text;
	encounter.latitude = self.location.latitude;
	encounter.longitude = self.location.longitude;
	encounter.voiceMessage = urlOfAudioMessage == nil ? @"" : urlOfAudioMessage;
	[[OTPoiService new] sendEncounter:encounter withSuccess: ^(OTEncounter *encounter) {
	    [self.navigationController popViewControllerAnimated:YES];
	} failure: ^(NSError *error) {
	}];
}

@end
