//
//  OTEditEncounterBehavior.m
//  entourage
//
//  Created by veronica.gliga on 10/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEditEncounterBehavior.h"
#import "OTCreateMeetingViewController.h"

@interface OTEditEncounterBehavior () <OTCreateMeetingViewControllerDelegate>

@property (nonatomic, strong, readwrite) OTEncounter *encounter;
@property (nonatomic, strong) NSNumber *tourId;
@property (nonatomic, assign) CLLocationCoordinate2D location;

@end

@implementation OTEditEncounterBehavior

- (void)doEdit:(OTEncounter *)encounter
       forTour:(NSNumber *)tourId
    andLocation:(CLLocationCoordinate2D) location {
    self.encounter = encounter;
    self.tourId = tourId;
    self.location = location;
    [self.owner performSegueWithIdentifier:@"OTCreateMeeting" sender:self];
}

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"OTCreateMeeting"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTCreateMeetingViewController *controller = (OTCreateMeetingViewController *)navController.topViewController;
        controller.encounter = self.encounter;
        [controller configureWithTourId:self.tourId andLocation:self.location];
        controller.delegate = self;
    }
    else
        return NO;
    return YES;
}

#pragma mark - OTCreateMeetingViewControllerDelegate

- (void)encounterSent:(OTEncounter *)encounter {
    self.encounter = encounter;
    [self.owner dismissViewControllerAnimated:YES completion:^{
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }];
}


@end
