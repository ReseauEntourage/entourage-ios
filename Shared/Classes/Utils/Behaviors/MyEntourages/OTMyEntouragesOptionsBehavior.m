//
//  OTMyEntouragesOptionsBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesOptionsBehavior.h"
#import "OTEntourage.h"
#import "OTEntourageEditorViewController.h"
#import "OTLocationManager.h"
#import "OTMyEntouragesOptionsViewController.h"
#import "OTMyEntouragesOptionsDelegate.h"
#import "OTAPIConsts.h"

@interface OTMyEntouragesOptionsBehavior () <EntourageEditorDelegate, OTMyEntouragesOptionsDelegate>

@property (nonatomic, weak) id<OTOptionsDelegate> optionsDelegate;
@property (nonatomic, strong) NSString *entourageType;

@end

@implementation OTMyEntouragesOptionsBehavior

- (void)configureWith:(id<OTOptionsDelegate>)optionsDelegate {
    self.optionsDelegate = optionsDelegate;
}

- (BOOL)prepareSegueForOptions:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"EntourageEditorSegue"]) {
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        OTEntourageEditorViewController *creatorController = (OTEntourageEditorViewController *)controller.topViewController;
        creatorController.type = self.entourageType;
        creatorController.location = [[OTLocationManager sharedInstance] defaultLocationForNewActions];
        creatorController.entourageEditorDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"OptionsSegue"]) {
        OTMyEntouragesOptionsViewController *controller = (OTMyEntouragesOptionsViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
    else
        return NO;
    return YES;
}

#pragma  mark - OTMyEntouragesOptionsDelegate

- (void)createAction {
    [self.owner performSegueWithIdentifier:@"EntourageEditorSegue" sender:nil];
}

- (void)createTour {
    [self.owner.navigationController popViewControllerAnimated:NO];
    [self.optionsDelegate createTour];
}

- (void)createEncounter {
    [self.owner.navigationController popViewControllerAnimated:NO];
    [self.optionsDelegate createEncounter];
}

#pragma mark - EntourageEditorDelegate

- (void)didEditEntourage:(OTEntourage *)entourage {
    [self.owner dismissViewControllerAnimated:YES completion:^() {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }];
}

@end
