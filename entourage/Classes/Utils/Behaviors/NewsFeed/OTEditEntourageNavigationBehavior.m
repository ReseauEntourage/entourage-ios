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
#import "OTEditEntourageTitleViewController.h"
#import "OTEditEntourageDescViewController.h"

@interface OTEditEntourageNavigationBehavior () < LocationSelectionDelegate, EditTitleDelegate, EditDescriptionDelegate>

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
        return YES;
    }
    if([segue.identifier isEqualToString:@"TitleEditSegue"]) {
        OTEditEntourageTitleViewController* controller = (OTEditEntourageTitleViewController *)destinationViewController;
        controller.delegate = self;
        controller.currentTitle = self.entourage.title;
        controller.currentEntourage = self.entourage;
        return YES;
    }
    if([segue.identifier isEqualToString:@"DescriptionEditSegue"]) {
        OTEditEntourageDescViewController* controller = (OTEditEntourageDescViewController *)destinationViewController;
        controller.delegate = self;
        controller.currentDescription = self.entourage.desc;
        controller.currentEntourage = self.entourage;
        return YES;
        
        //TO DO Segue for category
    }
    return NO;
}

- (void)editLocation:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"EditLocation" sender:self];
}

- (void)editTitle:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"TitleEditSegue" sender:self];
}

- (void)editDescription:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"DescriptionEditSegue" sender:self];
}

- (void)editCategory:(OTEntourage *)entourage {
    self.entourage = entourage;
   // [self.owner performSegueWithIdentifier:@"" sender:self];
}

#pragma mark - LocationSelectionDelegate

- (void)didSelectLocation:(CLLocation *)selectedLocation {
    self.entourage.location = selectedLocation;
    [self.editEntourageSource updateLocationTitle];
}

#pragma mark - EditTitleDelegate

- (void)titleEdited:(NSString *)title {
    self.entourage.title = title;
    [self.editEntourageSource updateTexts];
}

#pragma mark - EditDescriptionDelegate

- (void)descriptionEdited:(NSString *)description {
    self.entourage.desc = description;
    [self.editEntourageSource updateTexts];
}

@end
