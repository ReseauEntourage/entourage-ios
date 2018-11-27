//
//  OTAppDelegate.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"
#import "OTAppConfiguration.h"

NSString * const kLoginFailureNotification = @"loginFailureNotification";
NSString * const kUpdateBadgeCountNotification = @"updateBadgeCountNotification";

@interface OTAppDelegate () <UIApplicationDelegate, UNUserNotificationCenterDelegate>
@end

@implementation OTAppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Color of typed text in the search bar.
    NSDictionary *searchBarTextAttributes = @{
                                              NSForegroundColorAttributeName: UIColor.whiteColor,
                                              NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
                                              };
    [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]]
    .defaultTextAttributes = searchBarTextAttributes;
    
    // Color of the placeholder text in the search bar prior to text entry.
    NSDictionary *placeholderAttributes = @{
                                            NSForegroundColorAttributeName: UIColor.whiteColor,
                                            NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
                                            };
    
    // Color of the default search text.
    // NOTE: In a production scenario, "Search" would be a localized string.
    NSAttributedString *attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Avenue Jean Jaurès..." // 
                                    attributes:placeholderAttributes];
    [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]]
    .attributedPlaceholder = attributedPlaceholder;

    // To style the two image icons in the search bar (the magnifying glass
    // icon and the 'clear text' icon), replace them with different images.
//    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"custom_clear_x_high"]
//                      forSearchBarIcon:UISearchBarIconClear
//                                 state:UIControlStateHighlighted];
//    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"custom_clear_x"]
//                      forSearchBarIcon:UISearchBarIconClear
//                                 state:UIControlStateNormal];
//    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"custom_search"]
//                      forSearchBarIcon:UISearchBarIconSearch
//                                 state:UIControlStateNormal];


    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }
    
    [[OTAppConfiguration sharedInstance] configureApplication:application withOptions:launchOptions];
    
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [OTAppConfiguration applicationDidBecomeActive:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [OTAppConfiguration applicationWillEnterForeground:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [OTAppConfiguration applicationDidEnterBackground:application];
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    return [OTAppConfiguration application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [OTAppConfiguration handleApplication:app openURL:url];
}

#pragma mark - Configure push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [OTAppConfiguration applicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [OTAppConfiguration applicationDidFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {

    [OTAppConfiguration application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [OTAppConfiguration application:application didReceiveLocalNotification:notification];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    [OTAppConfiguration userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

@end
