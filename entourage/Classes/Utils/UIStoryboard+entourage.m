//
//  UIStoryboard+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 09/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIStoryboard+entourage.h"
#import "OTAppDelegate.h"
#import "OTStartupViewController.h"
#import "UINavigationController+entourage.h"

@implementation UIStoryboard (entourage)

+ (void)showStartup {
    [self showInitialViewControllerFromStoryboardNamed:@"Intro" addingNavigation:NO];
}

+ (void)showUserProfileDetails {
    [self showInitialViewControllerFromStoryboardNamed:@"UserProfileDetails" addingNavigation:YES];
}

+ (void)showSWRevealController {
    [self showInitialViewControllerFromStoryboardNamed:@"Main" addingNavigation:NO];
}

+ (UIStoryboard*)tourStoryboard {
    UIStoryboard *tourStoryboard = [UIStoryboard storyboardWithName:@"FeedItem" bundle:nil];
    return tourStoryboard;
}

+ (UIStoryboard*)entourageCreatorStoryboard {
    UIStoryboard *tourStoryboard = [UIStoryboard storyboardWithName:@"EntourageCreator" bundle:nil];
    return tourStoryboard;
}

#pragma mark - Private

+ (void)showInitialViewControllerFromStoryboardNamed:(NSString *)storyboardName addingNavigation:(BOOL)addNavigation {
    NSLog(@"showing %@.storyboard=============================", storyboardName);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    UIViewController *viewController = [storyboard instantiateInitialViewController];
    if(addNavigation) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [navController presentTransparentNavigationBar];
        viewController = navController;
    }
    window.rootViewController = viewController;
    [window makeKeyAndVisible];
}

@end
