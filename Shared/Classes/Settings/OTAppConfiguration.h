//
//  OTAppConfiguration.h
//  entourage
//
//  Created by Smart Care on 17/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Mixpanel/Mixpanel.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "OTDeepLinkService.h"
#import "OTPushNotificationsService.h"
#import "OTDebugLog.h"
#import "OTConsts.h"
#import "OTAppAppearance.h"
#import "OTEntourage.h"

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

// Configures if the geolcation is always requested
+ (BOOL)isGeolocationMandatory;

// Configures if the tour functionality is enabled/shown
+ (BOOL)supportsTourFunctionality;

// Configures if the solidarity guide is enabled/shown
+ (BOOL)supportsSolidarityGuideFunctionality;

+ (BOOL)supportsFacebookIntegration;

// Configures if the users are allowed to edit their profile
+ (BOOL)supportsProfileEditing;

// Configures if the intro tutorial is enabled/shown
+ (BOOL)shouldShowIntroTutorial;

// Configure if the user is allowed to login from the welcome page
+ (BOOL)shouldAllowLoginFromWelcomeScreen;

// Configures if the user is requested to upload a picture
+ (BOOL)shouldAlwaysRequestUserToUploadPicture;

// Configure if the user location is always requested
+ (BOOL)shouldAlwaysRequestUserLocation;

// Configures if the associtations section is displayed under user profile
+ (BOOL)shouldShowAssociationsOnUserProfile;

// Configures if the "+" button is displayed over feeds map
+ (BOOL)allowsAddingActionsFromMap;

// Configures if the feeds/map is visible or not
+ (BOOL)shouldHideFeedsAndMap;

// Configures if the feed pois are displayed on feeds map
// For Entourage app, the pois (solidarity guide items) are displayed only when the solidarity guide map is shown
// For PFP app, the pois (private circles and neighbourhoods) are displayed always
+ (BOOL)shouldShowPOIsOnFeedsMap;

// Configures if the user profile image is displayed on right of the newws feed item rows
+ (BOOL)shouldShowCreatorImagesForNewsFeedItems;

// Configures if the numbers of user actions is displayed in the user profile
+ (BOOL)shouldShowNumberOfUserActionsSection:(OTUser*)user;

// Configures if the numbers of user associations is displayed in the user profile
+ (BOOL)shouldShowNumberOfUserAssociationsSection:(OTUser*)user;

// Configures if the number of private circles are shown in the user profile
+ (BOOL)shouldShowNumberOfUserPrivateCirclesSection:(OTUser*)user;

// Configires if the map heatzone overlay is added on map for a specific antourage/feed item description
+ (BOOL)shouldShowMapHeatzoneForEntourage:(OTEntourage*)entourage;

// Configures if the user can close a specific feed item/group
+ (BOOL)supportsClosingFeedAction:(OTFeedItem*)item;

@end
