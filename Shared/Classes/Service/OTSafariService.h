//
//  OTSafariService.h
//  entourage
//
//  Created by Smart Care on 12/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTSafariService : NSObject
+ (void)launchInAppBrowserWithUrl:(NSURL*)url;
+ (void)launchInAppBrowserWithUrl:(NSURL*)url viewController:(UIViewController*)viewController;
+ (void)launchInAppBrowserWithUrlString:(NSString*)urlString viewController:(UIViewController*)viewController;
+ (void)launchFeedbackFormInController:(UIViewController*)controller;

+ (NSURL*)redirectUrlWithIdentifier:(NSString*)identifier;
@end
