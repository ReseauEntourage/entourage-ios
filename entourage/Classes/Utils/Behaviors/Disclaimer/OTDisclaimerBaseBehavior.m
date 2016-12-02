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
#import "OTUser.h"
#import "OTConsts.h"

@interface OTDisclaimerBaseBehavior () <DisclaimerDelegate>

@end

@implementation OTDisclaimerBaseBehavior

- (void)showDisclaimer {
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

- (NSAttributedString *)buildDisclaimerWithLink:(NSString *)originalString {
    NSString *stringToMakeInLink = OTLocalizedString(@"disclaimer_link_text");
    NSRange range = [originalString rangeOfString:stringToMakeInLink];
    if(range.location == NSNotFound)
        return [[NSAttributedString alloc] initWithString:originalString];
    NSString *url = [[NSUserDefaults standardUserDefaults].currentUser.type isEqualToString:USER_TYPE_PRO] ? PRO_ENTOURAGE_CREATION_CHART : PUBLIC_ENTOURAGE_CREATION_CHART;
    NSMutableAttributedString *source = [[NSMutableAttributedString alloc] initWithString:originalString];
    [source addAttribute:NSLinkAttributeName value:url range:range];
    return source;
}

#pragma mark - DisclaimerDelegate

- (void)disclaimerWasAccepted {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.owner dismissViewControllerAnimated:YES completion:nil];
}

- (void)disclaimerWasRejected {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.owner dismissViewControllerAnimated:YES completion:^{
        [self.owner dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
