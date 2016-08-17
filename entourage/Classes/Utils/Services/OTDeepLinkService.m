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

@implementation OTDeepLinkService

- (void)navigateTo:(NSNumber *)feedItemId withType:(NSString *)feedItemType {
    [SVProgressHUD show];
    
    [[[OTFeedItemFactory createForType:feedItemType] getStateInfo] loadById:feedItemId withSuccess:^(OTFeedItem *feedItem) {
        [SVProgressHUD dismiss];
        [self prepareControllers:feedItem];
    } error:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)prepareControllers:(OTFeedItem *)feedItem {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OTSWRevealViewController *revealController = [mainStoryboard instantiateInitialViewController];
    UIViewController *menuController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MenuNavController"];
    UINavigationController *mainController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainNavController"];
    revealController.frontViewController = mainController;
    revealController.rearViewController = menuController;
    
    UIStoryboard *activeFeedItemStorybard = [UIStoryboard storyboardWithName:@"ActiveFeedItem" bundle:nil];
    OTActiveFeedItemViewController *activeFeedItemController = (OTActiveFeedItemViewController *)[activeFeedItemStorybard instantiateInitialViewController];
    activeFeedItemController.feedItem = feedItem;
    [mainController setViewControllers:@[mainController.topViewController, activeFeedItemController]];
    
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    window.rootViewController = revealController;
    [window makeKeyAndVisible];

}

@end
