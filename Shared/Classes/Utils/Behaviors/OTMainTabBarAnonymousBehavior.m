//
//  OTMainTabBarAnonymousBehavior.m
//  entourage
//
//  Created by Grégoire Clermont on 16/05/2019.
//  Copyright © 2019 Entourage. All rights reserved.
//

#import "OTMainTabBarAnonymousBehavior.h"

@implementation OTMainTabBarAnonymousBehavior

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    NSUInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == MESSAGES_TAB_INDEX) {
        dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^(void){
           [OTAppState presentAuthenticationOverlay:tabBarController.selectedViewController];
        });
        return NO;
    }

    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // if for some reason we still end up on the messages tab (e.g. at initialization), switch to the main tab.
    if (tabBarController.selectedIndex == MESSAGES_TAB_INDEX) {
        tabBarController.selectedIndex = MAP_TAB_INDEX;
    }
}

@end
