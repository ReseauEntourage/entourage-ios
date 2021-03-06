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
#import "OTEntourageDisclaimerViewController.h"
#import "OTAPIConsts.h"

@interface OTDisclaimerBaseBehavior () <DisclaimerDelegate>
@property (nonatomic) BOOL createsEvent;
@end

@implementation OTDisclaimerBaseBehavior

- (void)showDisclaimer {
    UINavigationController *navigationViewController = self.owner.navigationController;
    [OTAppConfiguration configureNavigationControllerAppearance:navigationViewController withMainColor:[UIColor whiteColor] andSecondaryColor:[UIColor redColor]];
    self.createsEvent = NO;
    [self.owner performSegueWithIdentifier:@"DisclaimerSegue" sender:self];
}

- (void)showCreateEventDisclaimer {
    UINavigationController *navigationViewController = self.owner.navigationController;
    [OTAppConfiguration configureNavigationControllerAppearance:navigationViewController withMainColor:[UIColor whiteColor] andSecondaryColor:[UIColor redColor]];
    self.createsEvent = YES;
    [self.owner performSegueWithIdentifier:@"DisclaimerSegue" sender:self];
}

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"DisclaimerSegue"]) {
        UINavigationController *navigationViewController = segue.destinationViewController;
        [OTAppConfiguration configureNavigationControllerAppearance:navigationViewController withMainColor:[UIColor whiteColor] andSecondaryColor:[UIColor redColor]];
        
        UIViewController *destinationViewController = navigationViewController.topViewController;
        
        if ([destinationViewController isKindOfClass:[OTDisclaimerViewController class]]) {
            OTDisclaimerViewController *disclaimerViewController = (OTDisclaimerViewController *)destinationViewController;
            disclaimerViewController.disclaimerDelegate = self;
            disclaimerViewController.disclaimerText = self.disclaimerText;
        }
        
        if ([destinationViewController isKindOfClass:[OTEntourageDisclaimerViewController class]]) {
            OTEntourageDisclaimerViewController *disclaimerViewController = (OTEntourageDisclaimerViewController *)destinationViewController;
            disclaimerViewController.disclaimerDelegate = self;
            disclaimerViewController.isForCreatingEvent = self.createsEvent;

            if ([self.owner isKindOfClass:[OTEntourageEditorViewController class]]) {
                BOOL isFromHomeNeo = ((OTEntourageEditorViewController*) self.owner).isFromHomeNeo;
                disclaimerViewController.isFromHomeNeo = isFromHomeNeo;
                disclaimerViewController.tagNameAnalytic = ((OTEntourageEditorViewController*) self.owner).tagNameAnalytic;
            }
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
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont fontWithName:@"SFUIText-Light" size:17]};

    NSString *stringToMakeInLink = OTLocalizedString(@"disclaimer_link_text");
    NSRange range = [originalString rangeOfString:stringToMakeInLink];
    if(range.location == NSNotFound)
        return [[NSAttributedString alloc] initWithString:originalString attributes:attributes];
    NSString *url = IS_PRO_USER ? PRO_ENTOURAGE_CREATION_CHART : PUBLIC_ENTOURAGE_CREATION_CHART;
    NSMutableAttributedString *source = [[NSMutableAttributedString alloc] initWithString:originalString attributes:attributes];
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
        [self.owner dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end
