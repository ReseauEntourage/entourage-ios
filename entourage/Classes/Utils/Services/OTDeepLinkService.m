//
//  OTDeepLinkService.m
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDeepLinkService.h"
#import "OTAppDelegate.h"
#import "OTActiveFeedItemViewController.h"
#import "OTSWRevealViewController.h"
#import "SVProgressHUD.h"
#import "OTFeedItemFactory.h"
#import "OTUserViewController.h"

@implementation OTDeepLinkService

- (void)navigateTo:(NSNumber *)feedItemId withType:(NSString *)feedItemType {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createForType:feedItemType andId:feedItemId] getStateInfo] loadWithSuccess:^(OTFeedItem *feedItem) {
        [SVProgressHUD dismiss];
        [self prepareControllers:feedItem];
    } error:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (UIViewController *)getTopViewController {
    UIViewController *result = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([result isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealController = (SWRevealViewController*)result;
        result = revealController.frontViewController;
    }
    if([result isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController*)result;
        result = navController.topViewController;
    }
    return result;
}

- (void)showProfileFromAnywhereForUser:(NSNumber *)userId {
    UIStoryboard *userProfileStorybard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    UINavigationController *rootUserProfileController = (UINavigationController *)[userProfileStorybard instantiateInitialViewController];
    OTUserViewController *userController = (OTUserViewController *)rootUserProfileController.topViewController;
    userController.userId = userId;
    UIViewController *currentController = [self getTopViewController];
    while(currentController.presentedViewController)
        currentController = currentController.presentedViewController;
    [currentController presentViewController:rootUserProfileController animated:YES completion:nil];
}

- (void)navigateToLogin {
    UIStoryboard *introStorybard = [UIStoryboard storyboardWithName:@"Intro" bundle:nil];
    UIViewController *loginController = [introStorybard instantiateViewControllerWithIdentifier:@"OTLoginViewControllerIdentifier"];
    UIViewController *currentController = [self getTopViewController];
    [currentController showViewController:loginController sender:self];
}

- (void)prepareControllers:(OTFeedItem *)feedItem {
    OTSWRevealViewController *revealController = [self setupRevealController];
    UINavigationController *mainController = (UINavigationController *)revealController.frontViewController;
    UIStoryboard *activeFeedItemStorybard = [UIStoryboard storyboardWithName:@"ActiveFeedItem" bundle:nil];
    OTActiveFeedItemViewController *activeFeedItemController = (OTActiveFeedItemViewController *)[activeFeedItemStorybard instantiateInitialViewController];
    activeFeedItemController.feedItem = feedItem;
    [mainController setViewControllers:@[mainController.topViewController, activeFeedItemController]];
    [self updateAppWindow:revealController];
}

- (OTSWRevealViewController *)setupRevealController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OTSWRevealViewController *revealController = [mainStoryboard instantiateInitialViewController];
    UIViewController *menuController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MenuNavController"];
    UINavigationController *mainController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainNavController"];
    revealController.frontViewController = mainController;
    revealController.rearViewController = menuController;
    return revealController;
}

- (void)updateAppWindow:(OTSWRevealViewController *)revealController {
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    window.rootViewController = revealController;
    [window makeKeyAndVisible];
}

@end
