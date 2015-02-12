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

// Progress HUD
#import "MBProgressHUD.h"

#import <Social/Social.h>

@interface OTMeetingCalloutViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet OTPlayerView *player;
@property (strong, nonatomic) OTEncounter *encounter;
@property (strong, nonatomic) IBOutlet UILabel *theirVocalMsg;
@property (strong, nonatomic) IBOutlet UIButton *tweetButton;

@end

@implementation OTMeetingCalloutViewController

/********************************************************************************/
#pragma mark - lifecycle

- (void)viewWillDisappear:(BOOL)animated
{
    [self.player stopPlaying];
    [super viewWillDisappear:animated];
}

/********************************************************************************/
#pragma mark - Public Methods

- (void)configureWithEncouter:(OTEncounter *)encounter {
	self.encounter = encounter;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

	[formatter setDateFormat:@"dd/MM/yyyy à HH:mm"];

	NSString *date = [formatter stringFromDate:encounter.date];

	NSString *title = [NSString stringWithFormat:@"%@ %@ %@ %@, le %@", encounter.userName, NSLocalizedString(@"has_encountered", @""), encounter.streetPersonName, NSLocalizedString(@"here", @""), date];

	self.titleLabel.text = title;

	NSString *body = @"";

	if (encounter.voiceMessage.length == 0) {
		self.player.hidden = YES;
		self.theirVocalMsg.hidden = YES;
        self.tweetButton.hidden = YES;
	}
	else {
		self.player.hidden = NO;
		self.theirVocalMsg.hidden = NO;
		self.player.isRecordingMode = NO;
        self.tweetButton.hidden = NO;
		[MBProgressHUD showHUDAddedTo:self.view animated:YES];
		[self downloadAudio];
	}

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

- (void)downloadAudio {
	[[OTSoundCloudService new] downloadSoundAtURL:self.encounter.voiceMessage progress: ^(CGFloat percentageProgress) {
	} success: ^(NSData *streamData) {
	    [MBProgressHUD hideHUDForView:self.view animated:YES];
	    self.player.hidden = NO;
	    self.player.dowloadedFile = streamData;
	    self.player.isRecordingMode = NO;
	} failure: ^(NSError *error) {
	    [MBProgressHUD hideHUDForView:self.view animated:YES];
	    [[[UIAlertView alloc]
	      initWithTitle:@"Audio download failed"
	                   message:error.description
	                  delegate:nil
	         cancelButtonTitle:nil
	         otherButtonTitles:@"ok",
	      nil] show];
	}];
}

/********************************************************************************/
#pragma mark - IBActions
- (IBAction)tweetUrlOfVocalMsg:(id)sender {
    
    [[OTSoundCloudService new] infosOfTrackAtUrl:self.encounter.voiceMessage
                                         withKey:@"permalink_url"
                                        progress: ^(CGFloat percentageProgress) {}
                                         success: ^(NSString *url) {
                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                             SLComposeViewController *tweetSheet = [SLComposeViewController
                                                                                    composeViewControllerForServiceType:SLServiceTypeTwitter];
                                             [tweetSheet setInitialText:url];
                                             [self presentViewController:tweetSheet animated:YES completion:nil];
                                        } failure: ^(NSError *error) {
                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (IBAction)closeMe:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
