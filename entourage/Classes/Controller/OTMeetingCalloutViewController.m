//
//  OTMeetingCalloutViewController.m
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTMeetingCalloutViewController.h"
#import "OTConsts.h"
#import <MapKit/MKMapView.h>

// Model
#import "OTUser.h"
#import "OTEncounter.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "UIViewController+menu.h"

// Progress HUD
#import "MBProgressHUD.h"

#import <Social/Social.h>
#import "UIColor+entourage.h"


#define PADDING 15.0f

@interface OTMeetingCalloutViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (strong, nonatomic) NSString *locationName;

@end

@implementation OTMeetingCalloutViewController

/********************************************************************************/
#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"meetingTitle");
    [self.textView setTextContainerInset:UIEdgeInsetsMake(PADDING, PADDING, PADDING, PADDING)];
    [self locationTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    self.navigationController.navigationBarHidden = NO;
}

/********************************************************************************/
#pragma mark - Public Methods

- (void)configureWithEncouter:(OTEncounter *)encounter {
	self.encounter = encounter;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

	[formatter setDateFormat:@"dd/MM/yyyy à HH:mm"];

	NSString *date = [formatter stringFromDate:encounter.date];
    if(self.locationName == nil)
        self.locationName = @"";
    NSString *title = [NSString stringWithFormat:@"%@ et %@ se sont rencontrés à %@ le %@", [[NSUserDefaults standardUserDefaults] currentUser].firstName, encounter.streetPersonName, self.locationName, date];

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

- (void)locationTitle {
    dispatch_group_t group = dispatch_group_create();
    CLGeocoder *geocoder = [CLGeocoder new];
     CLLocation *location = [[CLLocation alloc] initWithLatitude:self.encounter.latitude longitude:self.encounter.longitude];
    dispatch_group_enter(group);
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error)
            NSLog(@"error: %@", error.description);
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark.thoroughfare !=  nil)
            self.locationName = placemark.thoroughfare;
        else
            self.locationName = placemark.locality;
        dispatch_group_leave(group);
    }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self configureWithEncouter:self.encounter];
    });
}

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
