//
//  OTEditEncounterBehavior.m
//  entourage
//
//  Created by veronica.gliga on 10/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEditEncounterBehavior.h"
#import "OTCreateMeetingViewController.h"
#import "OTOngoingTourService.h"
#import "OTMeetingCalloutViewController.h"
#import "NSUserDefaults+OT.h"

@interface OTEditEncounterBehavior () <OTCreateMeetingViewControllerDelegate, OTMeetingCalloutViewControllerDelegate>

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
    if(OTSharedOngoingTour.isOngoing || [NSUserDefaults standardUserDefaults].currentOngoingTour != nil)
        [self.owner performSegueWithIdentifier:@"OTCreateMeeting" sender:self];
    else
        [self.owner performSegueWithIdentifier:@"OTDisplayMeeting" sender:self];
}

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"OTCreateMeeting"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTCreateMeetingViewController *controller = (OTCreateMeetingViewController *)navController.topViewController;
        controller.encounter = self.encounter;
        [controller configureWithTourId:self.tourId andLocation:self.location];
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"OTDisplayMeeting"]) {
            UIViewController *destinationViewController = segue.destinationViewController;
            OTMeetingCalloutViewController *controller = (OTMeetingCalloutViewController *)destinationViewController;
            controller.encounter = self.encounter;
            controller.delegate = self;
        }
    else
        return NO;
    return YES;
}

#pragma mark - OTCreateMeetingViewControllerDelegate

- (void)encounterSent:(OTEncounter *)encounter {
    if(self.encounter == nil) {
        self.encounter = encounter;
        [self.owner dismissViewControllerAnimated:YES completion:^{
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }];
    } else {
        self.encounter = encounter;
        [self.owner dismissViewControllerAnimated:YES completion:^{
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            NSDictionary *info = @{ kNotificationEncounterEditedInfoKey: encounter };
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEncounterEdited object:nil userInfo:info];
        }];
    }
}

@end
