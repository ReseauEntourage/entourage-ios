//
//  OTEditEntourageNavigationBehavior.m
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEditEntourageNavigationBehavior.h"
#import "OTLocationSelectorViewController.h"
#import "OTEditEntourageTableSource.h"

@interface OTEditEntourageNavigationBehavior () < LocationSelectionDelegate>

@property (nonatomic, strong) OTEntourage *entourage;

@end

@implementation OTEditEntourageNavigationBehavior

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue {
    UIViewController *destinationViewController = segue.destinationViewController;
    if([segue.identifier isEqualToString:@"EditLocation"]) {
        [OTLogger logEvent:@"ChangeLocationClick"];
        OTLocationSelectorViewController* controller = (OTLocationSelectorViewController *)destinationViewController;
        controller.locationSelectionDelegate = self;
        controller.selectedLocation = self.entourage.location;
    }
    return NO;
}

- (void)editLocation:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"EditLocation" sender:self];
}

- (void)editTitle:(OTEntourage *)entourage {
    self.entourage = entourage;
}

- (void)editDescription:(OTEntourage *)entourage {
    self.entourage = entourage;
}

#pragma mark - LocationSelectionDelegate

- (void)didSelectLocation:(CLLocation *)selectedLocation {
    self.entourage.location = selectedLocation;
    [self.editEntourageSource updateLocationTitle];
}

@end
