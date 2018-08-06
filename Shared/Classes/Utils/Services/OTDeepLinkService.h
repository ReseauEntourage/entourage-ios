//
//  OTDeepLinkService.h
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTMainViewController.h"

@interface OTDeepLinkService : NSObject

- (void)navigateTo:(NSNumber *)feedItemId withType:(NSString *)feedItemType;
- (void)navigateTo:(NSString *)feedItemId;
- (UIViewController *)getTopViewController;
- (OTMainViewController *)popToMainViewController;
- (void)showProfileFromAnywhereForUser:(NSNumber *)userId;
- (void)handleDeepLink:(NSURL *)url;
- (void)handleUniversalLink:(NSURL *)url;
- (void)openWithWebView: (NSURL *)url;

@end
