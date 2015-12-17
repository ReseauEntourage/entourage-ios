//
//  OTAppDelegate.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"
#import "OTMessageViewController.h"

// Util
#import "UIFont+entourage.h"
#import "OTConsts.h"
#import "IQKeyboardManager.h"

const CGFloat OTNavigationBarDefaultFontSize = 18.f;

NSString *const kUserInfoSender = @"sender";
NSString *const kUserInfoObject = @"object";
NSString *const kUserInfoMessage = @"content";

@interface OTAppDelegate () <UIApplicationDelegate>

@end

@implementation OTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // start flurry
	[Flurry setCrashReportingEnabled:YES];
	[Flurry startSession:NSLocalizedString(@"FLURRY_API_KEY", @"")];
    [IQKeyboardManager sharedManager].enable = YES;

    // register for push notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    // configure appearence
    [self configureUIAppearance];
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

/**************************************************************************************************/
#pragma mark - Configure push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Push registration success with token : %@", token);
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Push registration failure : %@", [error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Push notification received");
    
    // Building the notification
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[userInfo objectForKey:kUserInfoSender]
                                                                       message:[userInfo objectForKey:kUserInfoObject]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Fermer"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {}];
        
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Afficher"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               OTMessageViewController *controller =
                                                               (OTMessageViewController *)[application.keyWindow.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"OTMessageViewController"];
                                                               
                                                               [application.keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
                                                               
                                                               [controller configureWithSender:[userInfo objectForKey:kUserInfoSender]
                                                                                     andObject:[userInfo objectForKey:kUserInfoObject]
                                                                                    andMessage:[userInfo objectForKey:kUserInfoMessage]];
                                                           }];
        [alert addAction:defaultAction];
        [alert addAction:openAction];
        [application.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // Retrieving the data
    NSDictionary *userInfo = notification.userInfo;
    
    // Building the notification
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[userInfo objectForKey:kUserInfoSender]
                                                                       message:[userInfo objectForKey:kUserInfoObject]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Fermer"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {}];
        
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Afficher"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               OTMessageViewController *controller =
                                                               (OTMessageViewController *)[application.keyWindow.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"OTMessageViewController"];

                                                               [application.keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
                                                               
                                                               [controller configureWithSender:[userInfo objectForKey:kUserInfoSender]
                                                                                     andObject:[userInfo objectForKey:kUserInfoObject]
                                                                                    andMessage:[userInfo objectForKey:kUserInfoMessage]];
                                                           }];
        [alert addAction:defaultAction];
        [alert addAction:openAction];
        [application.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

/**************************************************************************************************/
#pragma mark - Configure UIAppearance

- (void)configureUIAppearance {
	// UIStatusBar
	UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;

	// UINavigationBar
	UIImage *navigationBarImage = [UIImage imageNamed:@"bg-top-header.png"];
	UINavigationBar.appearance.barTintColor = [UIColor clearColor];
	[[UINavigationBar appearance] setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
	[UINavigationBar.appearance setBarStyle:UIBarStyleBlackTranslucent];

	UIFont *navigationBarFont = [UIFont calibriFontWithSize:OTNavigationBarDefaultFontSize];
	UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
	[UIBarButtonItem.appearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
	                                                      NSFontAttributeName : navigationBarFont } forState:UIControlStateNormal];
}

@end