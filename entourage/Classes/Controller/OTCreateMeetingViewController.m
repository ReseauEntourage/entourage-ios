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

// ViewController
#import "OTCreateAudioMessageViewController.h"

#import "NSUserDefaults+OT.h"
#import "OTUser.h"

#import "OTPlayerView.h"

@interface OTCreateMeetingViewController ()

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

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
}

- (void)configureWithLocation:(CLLocationCoordinate2D)location {
	self.location = location;
}

- (IBAction)addAudioMsgDidTap:(id)sender {
	OTCreateAudioMessageViewController *controller = (OTCreateAudioMessageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OTCreateAudioMessageViewController"];
	[self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)sendEncounter:(id)sender {
	OTEncounter *encounter = [OTEncounter new];
	encounter.date = [NSDate date];
	encounter.message = self.messageTextView.text;
	encounter.streetPersonName =  self.nameTextField.text;
	encounter.latitude = self.location.latitude;
	encounter.longitude = self.location.longitude;
	[[OTPoiService new] sendEncounter:encounter withSuccess: ^(OTEncounter *encounter) {
	    if (self.delegate) {
	        [self.delegate dismissPopoverWithEncounter:encounter];
		}
	} failure: ^(NSError *error) {
	}];
}

@end
