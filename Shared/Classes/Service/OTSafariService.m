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
#import "OTHTTPRequestManager.h"
#import "OTSWRevealViewController.h"
#import "UIColor+entourage.h"
#import "OTAppConfiguration.h"
#import "NSUserDefaults+OT.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"
#import "entourage-Swift.h"

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
        safariController.preferredBarTintColor = [ApplicationTheme shared].backgroundThemeColor;
        safariController.preferredControlTintColor = [UIColor whiteColor];
    }
    
    if (viewController) {
        [viewController presentViewController:safariController animated:YES completion:NULL];
        
    } else {
        OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
        UINavigationController *rootController = (UINavigationController*)appDelegate.window.rootViewController;
        if (rootController.navigationController.topViewController) {
            [rootController.navigationController.topViewController presentViewController:safariController animated:YES completion:nil];
        }
        else {
            [rootController presentViewController:safariController animated:YES completion:nil];
        }
    }
}

+ (void)launchInAppBrowserWithUrl:(NSURL*)url {
    [OTSafariService launchInAppBrowserWithUrl:url viewController:nil];
}

+ (void)launchFeedbackFormInController:(UIViewController*)controller {
    NSURL *feedbackUrl = [OTSafariService redirectUrlWithIdentifier:SUGGESTION_LINK_ID];
    [OTSafariService launchInAppBrowserWithUrl:feedbackUrl viewController:controller];
}

+ (NSURL*)redirectUrlWithIdentifier:(NSString*)identifier {
    NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS, identifier, TOKEN];
    NSString *urlString = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
    
    return [NSURL URLWithString:urlString];
}

@end
