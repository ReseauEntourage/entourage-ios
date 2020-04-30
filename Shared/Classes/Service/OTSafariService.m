//
//  OTSafariService.m
//  entourage
//
//  Created by Smart Care on 12/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTSafariService.h"
#import <SafariServices/SFSafariViewController.h>
#import <SafariServices/SFSafariViewControllerConfiguration.h>
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
    NSString *urlPath = urlString;
    NSString *httpPrefix = @"http";
    if ([urlString containsString:httpPrefix]) {
        NSRange httpRange = [urlString rangeOfString:httpPrefix];
        urlPath = [urlString substringFromIndex:httpRange.location];
    }
    [OTSafariService launchInAppBrowserWithUrl:[NSURL URLWithString:urlPath]
                                viewController:viewController];
}

+ (void)launchInAppBrowserWithUrl:(NSURL*)url viewController:(UIViewController*)viewController
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    NSString *urlPath = [[url absoluteString] stringByTrimmingCharactersInSet:set];
    
    if (![urlPath containsString:@"http"]) {
        urlPath = [NSString stringWithFormat:@"http://%@", urlPath];
    }
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlPath]]) {
        return;
    }
    
    NSURL *launchUrl = [NSURL URLWithString:urlPath];
    SFSafariViewController *safariController = [OTSafariService newSafariControllerWithUrl:launchUrl];
    
    if (viewController) {
        [OTAppConfiguration configureNavigationControllerAppearance:viewController.navigationController];
        [viewController presentViewController:safariController animated:YES completion:NULL];
    } else {
        OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
        id root = appDelegate.window.rootViewController;
        if ([root isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = (UITabBarController*)root;
            UINavigationController *navController = [tabBarController viewControllers].firstObject;
            
            if (navController.topViewController) {
                [navController presentViewController:safariController animated:YES completion:nil];
            }
            else {
                [navController presentViewController:safariController animated:YES completion:nil];
            }
        } else if ([root isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController*)root;
            if (navController.topViewController) {
                [navController presentViewController:safariController animated:YES completion:nil];
            }
            else {
                [navController presentViewController:safariController animated:YES completion:nil];
            }
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

+ (void)launchPrivacyPolicyFormInController:(UIViewController*)controller {
    NSURL *url = [OTSafariService redirectUrlWithIdentifier:PFP_API_URL_PRIVACY_POLICY_REDIRECT];
    [OTSafariService launchInAppBrowserWithUrl:url viewController:controller];
}

+ (NSURL*)redirectUrlWithIdentifier:(NSString*)identifier {
    NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS, identifier, TOKEN];
    NSString *urlString = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
    
    return [NSURL URLWithString:urlString];
}

+ (SFSafariViewController*)newSafariControllerWithUrl:(NSURL*)launchUrl
{
    return [OTSafariService newSafariControllerWithUrl:launchUrl entersReaderIfAvailable:NO];
}

+ (SFSafariViewController*)newSafariControllerWithUrl:(NSURL*)launchUrl
                              entersReaderIfAvailable:(BOOL)entersReaderIfAvailable
{
    SFSafariViewController *safariController;
    if (@available(iOS 11, *)) {
        SFSafariViewControllerConfiguration *config = [SFSafariViewControllerConfiguration new];
        config.entersReaderIfAvailable = entersReaderIfAvailable;
        safariController = [[SFSafariViewController alloc] initWithURL:(NSURL *)launchUrl
                                                         configuration:config];
    }
    else {
        safariController = [[SFSafariViewController alloc] initWithURL:(NSURL *)launchUrl
                                               entersReaderIfAvailable:entersReaderIfAvailable];
    }

    safariController.modalPresentationStyle = UIModalPresentationOverFullScreen;

    if (@available(iOS 10, *)) {
        safariController.preferredBarTintColor = [ApplicationTheme shared].backgroundThemeColor;
        safariController.preferredControlTintColor = [UIColor whiteColor];
    }

    return safariController;
}

@end
