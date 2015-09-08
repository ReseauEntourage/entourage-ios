//
//  OTCreateMeetingViewController.m
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTCreateMeetingViewController.h"
#import "OTMapViewController.h"

// Model
#import "OTEncounter.h"

// Services
#import "OTPoiService.h"
#import "OTEncounterService.h"


#import "NSUserDefaults+OT.h"
#import "OTUser.h"

#import "OTPlayerView.h"
#import "OTSoundCloudService.h"

// Social
#import <Social/Social.h>

// Progress HUD
#import "MBProgressHUD.h"


@interface OTCreateMeetingViewController ()

@property (strong, nonatomic) NSNumber *currentTourId;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation OTCreateMeetingViewController

/**************************************************************************************************/
#pragma mark - Life cycle

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
        
    [self createSendButton];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)createSendButton {
	UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    [menuButton setTarget:self];
	[menuButton setTitle:@"Valider"];
	[menuButton setAction:@selector(sendEncounter:)];
	[self.navigationItem setRightBarButtonItem:menuButton];
}

- (void)configureWithTourId:(NSNumber *)currentTourId andLocation:(CLLocationCoordinate2D)location {
    self.currentTourId = currentTourId;
	self.location = location;
}

- (void)sendEncounter:(id)sender {
    [self postEncounterWithCompletionBlock:^(OTEncounter *encounter){
        [self.encounters addObject:encounter];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)postEncounterWithCompletionBlock:(void (^)(OTEncounter *))success {
	OTEncounter *encounter = [OTEncounter new];
	encounter.date = [NSDate date];
	encounter.message = self.messageTextView.text;
	encounter.streetPersonName =  self.nameTextField.text;
	encounter.latitude = self.location.latitude;
	encounter.longitude = self.location.longitude;
    [[OTEncounterService new] sendEncounter:encounter withTourId:self.currentTourId
                                withSuccess:^(OTEncounter *sentEncounter) {
                                     if (success) {
                                         success(encounter);
                                     }
                                     else
                                     {
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }
                                    NSLog(@"%@", @"encounter success");
                                 } failure:^(NSError *error) {
                                     NSLog(@"%@", @"encounter failure");
                                 }];
}

@end
