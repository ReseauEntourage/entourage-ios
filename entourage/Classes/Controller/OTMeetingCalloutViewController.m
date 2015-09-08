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
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;

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

    self.player.hidden = YES;
    self.theirVocalMsg.hidden = YES;
    self.tweetButton.hidden = YES;
    self.facebookButton.hidden = YES;
    NSString *body = @"";

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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

/********************************************************************************/
#pragma mark - IBActions
- (IBAction)shareOnTwitter:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
}

- (IBAction)shareOnFacebook:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (IBAction)closeMe:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
