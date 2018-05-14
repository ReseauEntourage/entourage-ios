//
//  OTAppConfiguration.h
//  entourage
//
//  Created by Smart Care on 17/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mixpanel/Mixpanel.h"
#import "OTDeepLinkService.h"
#import "FBSDKCoreKit.h"
#import <UserNotifications/UserNotifications.h>
#import "OTPushNotificationsService.h"
#import "OTDebugLog.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Mixpanel/Mixpanel.h"
#import "OTConsts.h"
#import "OTAppAppearance.h"

@class EnvironmentConfigurationManager;

@interface OTAppConfiguration : NSObject

@property (nonatomic) OTPushNotificationsService *pushNotificationService;
@property (nonatomic) EnvironmentConfigurationManager *environmentConfiguration;

+ (OTAppConfiguration*)sharedInstance;
- (BOOL)configureApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions;
+ (UITabBarController*)configureMainTabBar;
+ (void)configureTabBarAppearance:(UITabBarController*)tabBarController;
+ (void)configureNavigationControllerAppearance:(UINavigationController*)navigationController;

+ (void)applicationDidBecomeActive:(UIApplication *)application;
+ (void)applicationWillEnterForeground:(UIApplication *)application;
+ (void)applicationDidEnterBackground:(UIApplication *)application;
+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler;
+ (void)handleAppLaunchFromNotificationCenter:(NSDictionary *)userInfo;
+ (BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url;
+ (void)clearUserData;

+ (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler;
+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

+ (NSInteger)applicationType;
+ (BOOL)isGeolocationMandatory;
+ (BOOL)supportsTourFunctionality;
+ (BOOL)supportsSolidarityGuideFunctionality;
+ (BOOL)supportsFacebookIntegration;
+ (BOOL)isMVP;
+ (BOOL)shouldShowIntroTutorial;
+ (BOOL)shouldAllowLoginFromWelcomeScreen;
+ (BOOL)shouldAlwaysRequestUserToUploadPicture;
+ (BOOL)shouldAlwaysRequestUserLocation;
+ (BOOL)shouldHideFeedsAndMap;

@end
