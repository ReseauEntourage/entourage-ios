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
#import <MessageUI/MessageUI.h>
#import <FirebaseMessaging/FirebaseMessaging.h>

#import "OTDeepLinkService.h"
#import "OTPushNotificationsService.h"
#import "OTDebugLog.h"
#import "OTConsts.h"
#import "OTAppAppearance.h"
#import "OTEntourage.h"

#define MAP_TAB_INDEX 0
#if !PFP
    #define MESSAGES_TAB_INDEX 2
    #define MENU_TAB_INDEX 3
#else
    #define MESSAGES_TAB_INDEX 1
    #define MENU_TAB_INDEX 2
#endif

@class EnvironmentConfigurationManager;

@interface OTAppConfiguration : NSObject

@property (nonatomic) OTPushNotificationsService *pushNotificationService;
@property (nonatomic) EnvironmentConfigurationManager *environmentConfiguration;

+ (OTAppConfiguration*)sharedInstance;
- (BOOL)configureApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions;
+ (UITabBarController*)configureMainTabBar;
+ (UITabBarController*)configureMainTabBarWithDefaultSelectedIndex:(NSInteger)selectedIndex;
+ (void)configureTabBarAppearance:(UITabBarController*)tabBarController;
+ (void)configureNavigationControllerAppearance:(UINavigationController*)navigationController;
+ (void)configureMailControllerAppearance:(MFMailComposeViewController *)mailController;
+ (void)configureActivityControllerAppearance:(UIActivityViewController *)controller
                                        color:(UIColor*)color;
+ (void)configureApplicationAppearance;
+ (void)updateAppearanceForMainTabBar;

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
+ (void)applicationDidRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler;
+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

+ (void)messaging:(FIRMessaging * _Nonnull)messaging didReceiveRegistrationToken:(NSString * _Nonnull)fcmToken;
+ (void)messaging:(FIRMessaging * _Nonnull)messaging didReceiveMessage:(FIRMessagingRemoteMessage * _Nonnull)remoteMessage;

+ (NSInteger)applicationType;
+ (BOOL)isApplicationTypeEntourage;
+ (BOOL)isApplicationTypeVoisinAge;

// Configures if the tour functionality is enabled/shown
+ (BOOL)supportsTourFunctionality;

// Configures if the solidarity guide is enabled/shown
+ (BOOL)supportsSolidarityGuideFunctionality;

+ (BOOL)supportsFacebookIntegration;

// Configures if the users are allowed to edit their profile
+ (BOOL)supportsProfileEditing;

// Configures if the intro tutorial is enabled/shown
+ (BOOL)shouldShowIntroTutorial:(OTUser * _Nonnull)user;

// Configure if the user is allowed to login from the welcome page
+ (BOOL)shouldAllowLoginFromWelcomeScreen;

// Configures if the user is requested to upload a picture
+ (BOOL)shouldAlwaysRequestUserToUploadPicture;

// Configures if the user is requested (forced) to add/edit action zone
+ (BOOL)shouldAlwaysRequestUserToAddActionZone;

// Configure if the user location is always requested
+ (BOOL)shouldAlwaysRequestUserLocation;

// Configures if the associtations section is displayed under user profile
+ (BOOL)shouldShowAssociationsOnUserProfile;

// Configures if the "+" button is displayed over feeds map
+ (BOOL)supportsAddingActionsFromMap;
    
// Configures if the options are displeyed on finger press over map
+ (BOOL)supportsAddingActionsFromMapOnLongPress;

// Configures if the feeds/map is visible or not
+ (BOOL)shouldHideFeedsAndMap;

// Configures if the feed pois are displayed on feeds map
// For Entourage app, the pois (solidarity guide items) are displayed only when the solidarity guide map is shown
// For PFP app, the pois (private circles and neighbourhoods) are displayed always
+ (BOOL)shouldShowPOIsOnFeedsMap;

// Configures if the user profile image is displayed on right of the newws feed item rows
+ (BOOL)shouldShowCreatorImagesForNewsFeedItems;

// Configures if the event disclaimer is shown before creating a new event
+ (BOOL)shouldShowAddEventDisclaimer;

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

// Itunes app id (currently only for prod version there is an app created in iTunes)
+ (NSString*)iTunesAppId;

// Specify if the action of "plus button" shows options or directly launches the entourage editor
+ (BOOL)shouldAutoLaunchEditorOnAddAction;

// Configures if the user can filter events only in the main feed list
+ (BOOL)supportsFilteringEvents;

// EMA-2286
+ (BOOL)shouldShowEntouragePrivacyDisclaimerOnCreation:(OTEntourage*)entourage;

/* Configures if the user has to accept some additional consent questions when creating new actions
*** EMA-2378
*** when a user creates an event, no change
*** - when a user creating an action has inputted all the information on Screen19.1, and the type is a "contribution", and the user clicks "Valider", no change
*** - when a user creating an action has inputted all the information on Screen19.1, and the type is an "ask for help", and the user clicks "Valider", add a series of questions that will help assess if the user has obtained the contribution.
 */
+ (BOOL)shouldAskForConsentWhenCreatingEntourage:(OTEntourage*)entourage;

/* Configures if the user has to accept some additional confindentiality questions when creating new actions: How the user will to choose to set Join requests on or off will work similarly, but it will only be possible for "Contribution" types of actions, not for "demandes" (Asks for help) for now. (EMA-2384)
 */
+ (BOOL)shouldAskForConfidentialityWhenCreatingEntourage:(OTEntourage*)entourage;

+ (NSDictionary *)community;

@end
