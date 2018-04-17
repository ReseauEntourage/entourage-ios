//
//  OTSafariService.m
//  entourage
//
//  Created by Smart Care on 12/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTSafariService.h"
#import <SafariServices/SFSafariViewController.h>
#import "OTAppDelegate.h"
#import "OTSWRevealViewController.h"
#import "UIColor+entourage.h"

@implementation OTSafariService

+ (void)launchInAppBrowserWithUrlString:(NSString*)urlString viewController:(UIViewController*)viewController
{
    [OTSafariService launchInAppBrowserWithUrl:[NSURL URLWithString:urlString] viewController:viewController];
}

+ (void)launchInAppBrowserWithUrl:(NSURL*)url viewController:(UIViewController*)viewController
{
    SFSafariViewController *safariController = [[SFSafariViewController alloc] initWithURL:url];
    safariController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    double iOSVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
    if (iOSVersion >= 10) {
        safariController.preferredBarTintColor = [UIColor appOrangeColor];
        safariController.preferredControlTintColor = [UIColor whiteColor];
    }
    
    if (viewController) {
        [viewController presentViewController:safariController animated:YES completion:NULL];
        
    } else {
        OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
        UINavigationController *rootController = (UINavigationController*)appDelegate.window.rootViewController;
        if (rootController.navigationController.topViewController) {
            [rootController.navigationController.topViewController presentViewController:safariController animated:YES completion:nil];
            
        } else if ([rootController isKindOfClass:[OTSWRevealViewController class]]) {
            OTSWRevealViewController *menuController = (OTSWRevealViewController*)rootController;
            UIViewController *activeController = menuController.frontViewController;
            if ([activeController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *activeNavController = (UINavigationController*)menuController.frontViewController;
                if (activeNavController.topViewController) {
                     [activeNavController.topViewController.navigationController presentViewController:safariController animated:YES completion:nil];
                } else {
                    [activeNavController presentViewController:safariController animated:YES completion:nil];
                }
            } else {
                [activeController.navigationController presentViewController:safariController animated:YES completion:nil];
            }
        }
        else {
            [rootController presentViewController:safariController animated:YES completion:nil];
        }
    }
}

+ (void)launchInAppBrowserWithUrl:(NSURL*)url {
    [OTSafariService launchInAppBrowserWithUrl:url viewController:nil];
}

@end
