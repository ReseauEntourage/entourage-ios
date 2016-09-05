//
//  OTDisclaimerBaseBehavior.m
//  entourage
//
//  Created by sergiu buceac on 9/5/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDisclaimerBaseBehavior.h"
#import "OTDisclaimerViewController.h"
#import "NSUserDefaults+OT.h"

@interface OTDisclaimerBaseBehavior () <DisclaimerDelegate>

@end

@implementation OTDisclaimerBaseBehavior

- (void)showDisclaimer {
    if (!self.wasDisclaimerAccepted)
        [self.owner performSegueWithIdentifier:@"DisclaimerSegue" sender:self];
}

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"DisclaimerSegue"]) {
        UINavigationController *navigationViewController = segue.destinationViewController;
        UIViewController *destinationViewController = navigationViewController.topViewController;
        if ([destinationViewController isKindOfClass:[OTDisclaimerViewController class]]) {
            OTDisclaimerViewController *disclaimerViewController = (OTDisclaimerViewController *)destinationViewController;
            disclaimerViewController.disclaimerDelegate = self;
            disclaimerViewController.disclaimerText = self.disclaimerText;
        }
    }
    else
        return NO;
    return YES;
}

- (NSString *)disclaimerText {
    return @"";
}

- (BOOL)wasDisclaimerAccepted {
    return NO;
}

- (NSString *)disclaimerStorageKey {
    return nil;
}

#pragma mark - DisclaimerDelegate

- (void)disclaimerWasAccepted {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.disclaimerStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.owner dismissViewControllerAnimated:YES completion:nil];
}

- (void)disclaimerWasRejected {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:self.disclaimerStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.owner dismissViewControllerAnimated:YES completion:^{
        [self.owner dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
