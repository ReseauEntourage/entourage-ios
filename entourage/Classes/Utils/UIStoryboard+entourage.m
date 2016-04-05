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

@implementation UIStoryboard (entourage)

+ (void)showStartup {
    [self showInitialViewControllerFromStoryboardNamed:@"Intro"];
}

+ (void)showSWRevealController {
    [self showInitialViewControllerFromStoryboardNamed:@"Main"];
}

+ (UIStoryboard*)tourStoryboard {
    UIStoryboard *tourStoryboard = [UIStoryboard storyboardWithName:@"Tour" bundle:nil];
    return tourStoryboard;
}


#pragma mark - Private

+ (void)showInitialViewControllerFromStoryboardNamed:(NSString *)storyboardName {
    NSLog(@"showing %@.storyboard=============================", storyboardName);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    UIViewController *viewController = [storyboard instantiateInitialViewController];
    window.rootViewController = viewController;
    [window makeKeyAndVisible];
}

@end
