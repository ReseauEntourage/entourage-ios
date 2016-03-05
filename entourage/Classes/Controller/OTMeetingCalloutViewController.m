//
//  OTMeetingCalloutViewController.m
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTMeetingCalloutViewController.h"

// Model
#import "OTUser.h"
#import "OTEncounter.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "UIViewController+menu.h"

// Progress HUD
#import "MBProgressHUD.h"

#import <Social/Social.h>


#define PADDING 15.0f

@interface OTMeetingCalloutViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@end

@implementation OTMeetingCalloutViewController

/********************************************************************************/
#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"COMPTE-RENDU DE RENCONTRE";
    [self setupCloseModal];
    [self.textView setTextContainerInset:UIEdgeInsetsMake(PADDING, PADDING, PADDING, PADDING)];
    [self configureWithEncouter:self.encounter];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

/********************************************************************************/
#pragma mark - Public Methods

- (void)configureWithEncouter:(OTEncounter *)encounter {
	self.encounter = encounter;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

	[formatter setDateFormat:@"dd/MM/yyyy à HH:mm"];

	NSString *date = [formatter stringFromDate:encounter.date];

	NSString *title = [NSString stringWithFormat:@"%@ %@ %@ %@, le %@", [[NSUserDefaults standardUserDefaults] currentUser].firstName, NSLocalizedString(@"has_encountered", @""), encounter.streetPersonName, NSLocalizedString(@"here", @""), date];

    NSString *bodyText = title;

	if (encounter.message.length != 0) {
		bodyText = [NSString stringWithFormat:@"%@ \n\n%@", bodyText, encounter.message];
	}

	[self.textView setText: bodyText];
    CGSize sizeThatFitsTextView = [self.textView sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT)];
    self.textViewHeightConstraint.constant = sizeThatFitsTextView.height;
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
