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

// Social
#import <Social/Social.h>

// Progress HUD
#import "MBProgressHUD.h"


@interface OTCreateMeetingViewController ()

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet OTPlayerView *playerView;
@property (strong, nonatomic) IBOutlet UISwitch *twitterShareSwitch;
@property (strong, nonatomic) IBOutlet UILabel *twitterShareLabel;

@end

@implementation OTCreateMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
	self.firstLabel.text = [NSString stringWithFormat:@"%@ et", currentUser.firstName];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd/MM/yyyy"];

	NSString *dateString = [formatter stringFromDate:[NSDate date]];

	self.dateLabel.text = [NSString stringWithFormat:@"se sont rencontrés ici le %@", dateString];

	self.messageTextView.layer.borderWidth = 1;
	self.messageTextView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    
	self.playerView.isRecordingMode = YES;
    
    [self createSendButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)createSendButton {
	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    [menuButton setTarget:self];
	[menuButton setTitle:@"Valider"];
	[menuButton setAction:@selector(sendEncounter:)];
	[self.navigationItem setRightBarButtonItem:menuButton];
}

- (void)configureWithLocation:(CLLocationCoordinate2D)location {
	self.location = location;
}

- (void)sendEncounter:(id)sender {
	if ([self.playerView hasRecordedFile]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"dd/MM/yyyy à HH:mm"];
		NSString *date = [formatter stringFromDate:[NSDate date]];
		NSString *title = [NSString stringWithFormat:@"%@ %@ %@, le %@", [[NSUserDefaults standardUserDefaults] currentUser].firstName, NSLocalizedString(@"has_encountered", @""), self.nameTextField.text, date];


        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
		OTSoundCloudService *service = [OTSoundCloudService new];
		[service uploadSoundAtURL:self.playerView.recordedURL
		                    title:title
		                 progress: ^(CGFloat percentageProgress) {}
		                  success: ^(NSString *uploadLocation)
		{
		    [self postEncounterWithAudioFile:uploadLocation withCompletionBlock:^(OTEncounter *encounter){
                if([self.twitterShareSwitch isOn])
                {
                    [service infosOfTrackAtUrl:uploadLocation
                                         withKey:@"permalink_url"
                                       progress:^(CGFloat percentageProgress) {}
                                        success:^(NSString *permanentUrl) {
                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                            NSString *message = [NSString stringWithFormat:@"Ecoutez le message que j'ai enregistré avec %@ par l'application Entourage : %@ #entourage @R_Entourage", encounter.streetPersonName, permanentUrl];
                                            [self composeTweetWithString:message];
                                        }
                                        failure:^(NSError *error) {
                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                            NSLog(@"error = %@", error);
                                        }];
                }else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
		}

		 failure: ^(NSError *error)
		{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
		    NSLog(@"error = %@", error);
		}];
	}
	else {
        [self postEncounterWithAudioFile:nil withCompletionBlock:^(OTEncounter *encounter){
            if([self.twitterShareSwitch isOn])
            {
                NSString *message = [NSString stringWithFormat:@"J'ai rencontré %@ #entourage @R_Entourage",encounter.streetPersonName];
                [self composeTweetWithString:message];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
	}
}

- (void)postEncounterWithAudioFile:(NSString *)urlOfAudioMessage
                   withCompletionBlock:(void (^)(OTEncounter *))blockName {
	OTEncounter *encounter = [OTEncounter new];
	encounter.date = [NSDate date];
	encounter.message = self.messageTextView.text;
	encounter.streetPersonName =  self.nameTextField.text;
	encounter.latitude = self.location.latitude;
	encounter.longitude = self.location.longitude;
	encounter.voiceMessage = urlOfAudioMessage == nil ? @"" : urlOfAudioMessage;
	[[OTPoiService new] sendEncounter:encounter withSuccess: ^(OTEncounter *encounter) {
        if(blockName)
        {
            blockName(encounter);
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
	} failure: ^(NSError *error) {
	}];
}

- (void)composeTweetWithString:(NSString *)message
{
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:message];
    [self presentViewController:tweetSheet animated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
