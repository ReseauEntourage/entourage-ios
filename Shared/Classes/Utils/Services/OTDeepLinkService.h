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

- (void)navigateToFeedWithNumberId:(NSNumber *)feedItemId
                          withType:(NSString *)feedItemType;

- (void)navigateToFeedWithStringId:(NSString *)feedItemId;

- (void)navigateToFeedWithNumberId:(NSNumber *)feedItemId
                          withType:(NSString *)feedItemType
                         groupType:(NSString*)groupType;

- (UIViewController *)getTopViewController;
- (OTMainViewController *)popToMainViewController;
- (void)showProfileFromAnywhereForUser:(NSString *)userId isFromLaunch:(BOOL) isFromLaunch;
- (void)handleDeepLink:(NSURL *)url;
+ (BOOL)isUniversalLink:(NSURL *)url;
- (void)handleUniversalLink:(NSURL *)url;
- (void)openWithWebView: (NSURL *)url;

-(void)showDetailPoiViewControllerWithId:(NSNumber*)poiId;
@end
