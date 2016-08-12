//
//  OTMyEntouragesOptionsBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesOptionsBehavior.h"
#import "OTEntourage.h"
#import "OTEntourageCreatorViewController.h"
#import "OTLocationManager.h"
#import "OTMyEntouragesOptionsViewController.h"
#import "OTMyEntouragesOptionsDelegate.h"

@interface OTMyEntouragesOptionsBehavior () <EntourageCreatorDelegate, OTMyEntouragesOptionsDelegate>

@property (nonatomic, weak) id<OTOptionsDelegate> optionsDelegate;
@property (nonatomic, strong) NSString *entourageType;

@end

@implementation OTMyEntouragesOptionsBehavior

- (BOOL)prepareSegueForOptions:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"EntourageCreateSegue"]) {
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        OTEntourageCreatorViewController *creatorController = (OTEntourageCreatorViewController *)controller.topViewController;
        creatorController.type = self.entourageType;
        creatorController.location = [OTLocationManager sharedInstance].currentLocation;
        creatorController.entourageCreatorDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"OptionsSegue"]) {
        OTMyEntouragesOptionsViewController *controller = (OTMyEntouragesOptionsViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
    else
        return NO;
    return YES;
}

- (void)configureWith:(id<OTOptionsDelegate>)optionsDelegate {
    self.optionsDelegate = optionsDelegate;
}

#pragma  mark - OTMyEntouragesOptionsDelegate

- (void)createDemand {
    self.entourageType = ENTOURAGE_DEMANDE;
    [self.owner performSegueWithIdentifier:@"EntourageCreateSegue" sender:self];
}

- (void)createContribution {
    self.entourageType = ENTOURAGE_CONTRIBUTION;
    [self.owner performSegueWithIdentifier:@"EntourageCreateSegue" sender:self];
}

- (void)createTour {
    [self.owner.navigationController popViewControllerAnimated:NO];
    [self.optionsDelegate createTour];
}

#pragma mark - EntourageCreatorDelegate

- (void)didCreateEntourage {
    [self.owner dismissViewControllerAnimated:YES completion:^() {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }];
}

@end
