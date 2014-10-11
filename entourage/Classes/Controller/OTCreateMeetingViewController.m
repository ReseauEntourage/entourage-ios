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

@interface OTCreateMeetingViewController ()

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;

@end

@implementation OTCreateMeetingViewController

- (void)configureWithLocation:(CLLocationCoordinate2D)location
{
    self.location = location;
}

- (IBAction)sendEncounter:(id)sender
{
    OTEncounter *encounter = [OTEncounter new];
    encounter.date = [NSDate date];
    encounter.message = self.messageTextView.text;
    encounter.streetPersonName =  self.nameTextField.text;
    encounter.latitude = self.location.latitude;
    encounter.longitude = self.location.longitude;
    [[OTPoiService new] sendEncounter:encounter withSuccess:^(OTEncounter *encounter) {
        if (self.delegate)
        {
            [self.delegate dismissPopoverWithEncounter:encounter];
        }
    } failure:^(NSError *error) {
        
    }];
}
@end
