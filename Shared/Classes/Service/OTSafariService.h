//
//  OTSafariService.h
//  entourage
//
//  Created by Smart Care on 12/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SafariServices/SFSafariViewController.h>

@interface OTSafariService : NSObject
+ (void)launchInAppBrowserWithUrl:(NSURL*)url;
+ (void)launchInAppBrowserWithUrl:(NSURL*)url viewController:(UIViewController*)viewController;
+ (void)launchInAppBrowserWithUrlString:(NSString*)urlString viewController:(UIViewController*)viewController;
+ (void)launchFeedbackFormInController:(UIViewController*)controller;
+ (void)launchPrivacyPolicyFormInController:(UIViewController*)controller;

+ (NSURL*)redirectUrlWithIdentifier:(NSString*)identifier;

+ (SFSafariViewController*)newSafariControllerWithUrl:(NSURL*)launchUrl;
+ (SFSafariViewController*)newSafariControllerWithUrl:(NSURL*)launchUrl entersReaderIfAvailable:(BOOL)entersReaderIfAvailable;
@end
