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

+ (UIStoryboard *)introStoryboard
{
    return [UIStoryboard storyboardWithName:@"Intro" bundle:nil];
}

+ (UIStoryboard *)onboardingStoryboard
{
    return [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
}

+ (UIStoryboard *)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

+ (UIStoryboard *)myEntouragesStoryboard
{
    return [UIStoryboard storyboardWithName:@"MyEntourages" bundle:nil];
}

+ (UIStoryboard *)activeFeedsStoryboard
{
    return [UIStoryboard storyboardWithName:@"ActiveFeedItem" bundle:nil];
}

+ (UIStoryboard*)entourageEditorStoryboard {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EntourageEditor" bundle:nil];
    return storyboard;
}

+ (UIStoryboard *)aboutStoryboard
{
    return [UIStoryboard storyboardWithName:@"About" bundle:nil];
}

+ (UIStoryboard *)userProfileStoryboard
{
    return [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
}


+ (void)showTabBarControllerFromStoryboardNamed:(NSString *)storyboardName {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    UITabBarController *viewController = (UITabBarController*)[storyboard instantiateViewControllerWithIdentifier:storyboardName];
    window.rootViewController = viewController;
    [window makeKeyAndVisible];
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
