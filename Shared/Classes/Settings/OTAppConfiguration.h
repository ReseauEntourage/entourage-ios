//
//  OTAppConfiguration.h
//  entourage
//
//  Created by Smart Care on 17/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OTVersionInfo.h"
#import "OTDebugLog.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Mixpanel/Mixpanel.h"
#import "OTDeepLinkService.h"
#import "FBSDKCoreKit.h"
#import "OTLocationManager.h"
#import <UserNotifications/UserNotifications.h>
#import "OTUser.h"
#import "A0SimpleKeychain.h"
#import "OTConsts.h"
#import "IQKeyboardManager.h"
#import "NSUserDefaults+OT.h"
#import "UIStoryboard+entourage.h"
#import "OTPushNotificationsService.h"
#import "OTPictureUploadService.h"
#import "OTAuthService.h"
#import "OTDeepLinkService.h"
#import "OTMainViewController.h"
#import "OTOngoingTourService.h"
#import "SVProgressHUD.h"
#import "entourage-Swift.h"
#import "UIColor+entourage.h"
#import "OTUnreadMessagesService.h"
#import "OTLoginViewController.h"
#import "OTLostCodeViewController.h"
#import "OTPhoneViewController.h"
#import "OTCodeViewController.h"
#import "Mixpanel/Mixpanel.h"
#import "OTDeepLinkService.h"
#import "FBSDKCoreKit.h"
#import <UserNotifications/UserNotifications.h>
#import "OTPushNotificationsService.h"

@interface OTAppConfiguration : NSObject

+ (OTAppConfiguration*)sharedInstance;
- (BOOL)configureApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions;

+ (void)applicationDidBecomeActive:(UIApplication *)application;
+ (void)applicationWillEnterForeground:(UIApplication *)application;
+ (void)applicationDidEnterBackground:(UIApplication *)application;
+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler;

+ (void)handleAppLaunchFromNotificationCenter:(NSDictionary *)userInfo;
+ (BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url;

+ (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler;
+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

@end
