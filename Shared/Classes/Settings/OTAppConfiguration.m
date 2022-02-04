//
//  OTAppConfiguration.m
//  entourage
//
//  Created by Smart Care on 17/04/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import <IQKeyboardManager/IQKeyboardManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SimpleKeychain/A0SimpleKeychain.h>

#import "OTAppConfiguration.h"
#import "OTDeepLinkService.h"
#import "OTPushNotificationsData.h"
#import "OTVersionInfo.h"
#import "OTLocationManager.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "UIStoryboard+entourage.h"
#import "OTPushNotificationsService.h"
#import "OTPictureUploadService.h"
#import "OTAuthService.h"
#import "OTOngoingTourService.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIColor+entourage.h"
#import "OTUnreadMessagesService.h"
#import "OTAppDelegate.h"
#import "UIStoryboard+entourage.h"
#import "OTAppState.h"
#import "OTMyEntouragesViewController.h"
#import "UIImage+processing.h"
#import "OTAPIConsts.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GooglePlaces/GMSPlacesClient.h>
#import "OTMainTabBarAnonymousBehavior.h"
#import "OTAnalyticsObserver.h"
#import "entourage-Swift.h"

@import Firebase;

const CGFloat OTNavigationBarDefaultFontSize = 17.f;

@interface OTAppConfiguration ()

@property (nonatomic, strong) id<UITabBarControllerDelegate> mainTabBarBehavior;

@end

@implementation OTAppConfiguration

+ (OTAppConfiguration*)sharedInstance {
    static OTAppConfiguration* sharedInstance;
    static dispatch_once_t debugLogToken;
    dispatch_once(&debugLogToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pushNotificationService = [OTPushNotificationsService new];
        self.environmentConfiguration = [[EnvironmentConfigurationManager alloc] initWithBundleId:[[NSBundle mainBundle] bundleIdentifier]];
    }
    return self;
}

- (BOOL)configureApplication:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {

//    [[OTDebugLog sharedInstance] setConsoleOutput];
    

    [self configureFirebase];
    [OTAnalyticsObserver init];
    [FBSDKSettings initialize];
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
    //Controllers where IQKeyboardManager has to be disabled inside onboarding V2
    [[IQKeyboardManager sharedManager].disabledDistanceHandlingClasses addObject:[OTOnboardingPhoneViewController class]];
    [[IQKeyboardManager sharedManager].disabledToolbarClasses addObject:[OTOnboardingPhoneViewController class]];
    
    [self configurePushNotifcations];
    [self configureAnalyticsWithOptions:launchOptions];
    [self configurePhotoUploadingService];
    [self configureGooglePlacesClient];
    
    [OTAppConfiguration configureApplicationAppearance];
    [OTAppState launchApplicatioWithOptions:launchOptions];
    
    return YES;
}

- (void)popToLogin {
    [OTAppState returnToLogin];
}

- (void)updateBadge: (NSNotification *) notification {
    NSNumber *totalUnreadCount = [notification.object numberForKey:kNotificationTotalUnreadCountKey];
    [UIApplication sharedApplication].applicationIconBadgeNumber = totalUnreadCount.integerValue;
}

+ (void)clearUserData {
    [[NSUserDefaults standardUserDefaults] setCurrentUser:nil];
    [[NSUserDefaults standardUserDefaults] setTemporaryUser:nil];
    [[NSUserDefaults standardUserDefaults] setCurrentOngoingTour:nil];
    [[NSUserDefaults standardUserDefaults] setTourPoints:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"noMoreDemand"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"nbOfLaunch"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isExpertMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPhone];
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPassword];
}

#pragma mark - Application State

+ (void)applicationDidBecomeActive:(UIApplication *)application {
    // Call the 'activateApp' method to log an app event for use
    // in analytics and advertising reporting.
    [FBSDKAppEvents.shared activateApp];

    [OTPushNotificationsService refreshPushTokenIfConfigurationChanged];
    
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                [FIRAnalytics setUserPropertyString:@"YES" forName:@"EntourageNotifEnable"];
            }
            else {
                [FIRAnalytics setUserPropertyString:@"NO" forName:@"EntourageNotifEnable"];
            }
        }];
    }
}

+ (void)applicationWillEnterForeground:(UIApplication *)application {
    
    if ([NSUserDefaults standardUserDefaults].currentUser) {
        [[OTLocationManager sharedInstance] refreshAuthorizationStatus];
        [[OTLocationManager sharedInstance] startLocationUpdates];
    }
}

+ (void)applicationDidEnterBackground:(UIApplication *)application {
    if([OTOngoingTourService sharedInstance].isOngoing) {
        return;
    }
    [[OTLocationManager sharedInstance] stopLocationUpdates];
}

+ (void)handleAppLaunchFromNotificationCenter:(NSDictionary *)userInfo {
    OTPushNotificationsData *pnData = [OTPushNotificationsData createFrom:userInfo];
    if ([pnData.notificationType isEqualToString:@APNOTIFICATION_JOIN_REQUEST]) {
        [[OTDeepLinkService new] navigateToFeedWithNumberId:pnData.joinableId withType:pnData.joinableType];
    }
}

+ (BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url
{
    [[OTDeepLinkService new] handleDeepLink:url];
    return YES;
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;

        [[OTDeepLinkService new] handleUniversalLink:url];
    }
    return true;
}

#pragma mark - App Configurations

- (void)configurePushNotifcations
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToLogin) name:[kLoginFailureNotification copy] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge:) name:[kUpdateTotalUnreadCountNotification copy] object:nil];

    [OTPushNotificationsService refreshPushToken];
    [OTPushNotificationsService requestProvisionalAuthorizationsIfAdequate];
}

- (void)configurePhotoUploadingService {
    [OTPictureUploadService configure];
}

- (void)configureCrashReporting
{
    [FIRApp configure];
}

- (void)configureGooglePlacesClient {
    [GMSPlacesClient provideAPIKey:[self.environmentConfiguration GooglePlaceApiKey]];
}

- (void)configureFirebase
{
    NSString *firebaseConfigFileName = nil;
    
    firebaseConfigFileName = [self.environmentConfiguration runsOnStaging] ?
    @"GoogleService-Info-social.entourage.ios.beta" :
    @"GoogleService-Info";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:firebaseConfigFileName ofType:@"plist"];
    FIROptions *options = [[FIROptions alloc] initWithContentsOfFile:filePath];
    
    if (!options) return;
    
    [[FIRConfiguration sharedInstance] setLoggerLevel:FIRLoggerLevelMin];//FIRLoggerLevelDebug
    [FIRApp configureWithOptions:options];
    [FIRAnalytics setUserPropertyString:[OTAuthService currentUserAuthenticationLevel]
                                forName:@"AuthenticationLevel"];
    [FIRMessaging messaging].delegate = (id<FIRMessagingDelegate>)[UIApplication sharedApplication].delegate;
}

- (void)configureAnalyticsWithOptions:(NSDictionary *)launchOptions
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser) {
        [[OTAuthService new] getDetailsForUser:currentUser.uuid success:^(OTUser *user) {
            [NSUserDefaults standardUserDefaults].currentUser = user;
            [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:^(NSError *error) {
            NSLog(@"@fails getting user %@", error.description);
        }];
        
        if (!currentUser.isAnonymous) {
          [OTLogger setupAnalyticsWithUser:currentUser];
        }
    }
}

+ (UITabBarController*)configureMainTabBar {
    
    NSInteger selectedIndex = MAP_TAB_INDEX;
    UITabBarController *tabBarController = [OTAppConfiguration configureMainTabBarWithDefaultSelectedIndex:selectedIndex];
    
    return tabBarController;
}

+ (void)updateAppearanceForMainTabBar {

    id rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootController isKindOfClass:[UITabBarController class]]) {
        [OTAppConfiguration configureTabBarAppearance:(UITabBarController*)rootController];
    } else if ([rootController isKindOfClass:[UINavigationController class]]) {
        [OTAppConfiguration configureNavigationControllerAppearance:(UINavigationController*)rootController];
    }
}

+ (UITabBarController*)configureMainTabBarWithDefaultSelectedIndex:(NSInteger)selectedIndex
{
    OTMainTabbarViewController *newTab = [[OTMainTabbarViewController alloc]init];
    
    newTab.selectedIndex = selectedIndex;
    [newTab boldSelectedItem];
    return newTab;
}

+ (void)configureApplicationAppearance
{
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    UIColor *primaryNavigationBarTintColor = [UIColor whiteColor];
    UIColor *secondaryNavigationBarTintColor = [UIColor appOrangeColor];
    UIColor *backgroundThemeColor = [UIColor appOrangeColor];
    UIColor *titleColor = [UIColor appGreyishBrownColor];
    UIColor *subtitleColor = [UIColor appGreyishColor];
    UIColor *tableViewBgColor = [UIColor groupTableViewBackgroundColor];
    UIColor *addActionButtonColor = [UIColor appOrangeColor];
    
    [[ApplicationTheme shared] setPrimaryNavigationBarTintColor:primaryNavigationBarTintColor];
    [[ApplicationTheme shared] setSecondaryNavigationBarTintColor:secondaryNavigationBarTintColor];
    [[ApplicationTheme shared] setBackgroundThemeColor:backgroundThemeColor];
    [[ApplicationTheme shared] setTableViewBackgroundColor: tableViewBgColor];
    [[ApplicationTheme shared] setTitleLabelColor: titleColor];
    [[ApplicationTheme shared] setSubtitleLabelColor: subtitleColor];
    [[ApplicationTheme shared] setAddActionButtonColor: addActionButtonColor];
    
    UINavigationBar.appearance.backgroundColor = primaryNavigationBarTintColor;
    UINavigationBar.appearance.barTintColor = primaryNavigationBarTintColor;
    UINavigationBar.appearance.tintColor = secondaryNavigationBarTintColor;
    
    UIFont *navigationBarFont = [UIFont systemFontOfSize:OTNavigationBarDefaultFontSize weight:UIFontWeightRegular];
    UIColor *navigationBarTextColor = [UIColor appOrangeColor];
    
    UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : navigationBarTextColor };
    [UIBarButtonItem.appearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : navigationBarTextColor,
                                                          NSFontAttributeName : navigationBarFont } forState:UIControlStateNormal];
    
    UIPageControl.appearance.backgroundColor = [UIColor whiteColor];
    UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor appGreyishBrownColor];
}

+ (void)configureTabBarAppearance:(UITabBarController*)tabBarController
{
    for (UINavigationController *navController in tabBarController.viewControllers) {
        if ([navController isKindOfClass:UINavigationController.class]) {
            [OTAppConfiguration configureNavigationControllerAppearance:navController];
        }
    }
}

+ (void)configureMailControllerAppearance:(MFMailComposeViewController *)mailController {
    mailController.navigationBar.backgroundColor = [[ApplicationTheme shared] primaryNavigationBarTintColor];
    mailController.navigationBar.tintColor = [[ApplicationTheme shared] secondaryNavigationBarTintColor];
    mailController.navigationBar.barTintColor = [[ApplicationTheme shared] primaryNavigationBarTintColor];
    mailController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [[ApplicationTheme shared] secondaryNavigationBarTintColor]};
    [mailController.navigationBar setTranslucent:NO];
    [mailController.navigationBar setOpaque:NO];
}

+ (void)configureActivityControllerAppearance:(UIActivityViewController *)controller
                                        color:(UIColor*)color {
    [UIApplication sharedApplication].keyWindow.tintColor = color;
    UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : color };
    [UIBarButtonItem.appearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : color} forState:UIControlStateNormal];
}

+ (void)configureNavigationControllerAppearance:(UINavigationController*)navigationController
{
    [OTAppConfiguration configureApplicationAppearance];
    
    navigationController.automaticallyAdjustsScrollViewInsets = NO;
    
    UINavigationBar *navigationBar = navigationController.navigationBar;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [UINavigationBarAppearance new];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.backgroundColor = [[ApplicationTheme shared] primaryNavigationBarTintColor];
        NSDictionary *textAttributes = @{
            NSForegroundColorAttributeName: [[ApplicationTheme shared] topTilteNavBarColor]
        };
        navBarAppearance.titleTextAttributes = textAttributes;
        navBarAppearance.largeTitleTextAttributes = textAttributes;
        navigationBar.standardAppearance = navBarAppearance;
        navigationBar.scrollEdgeAppearance = navBarAppearance;
    } else
    #endif
    {
        navigationBar.backgroundColor = [[ApplicationTheme shared] primaryNavigationBarTintColor];
        navigationBar.tintColor = [[ApplicationTheme shared] secondaryNavigationBarTintColor];
        navigationBar.barTintColor = [[ApplicationTheme shared] primaryNavigationBarTintColor];
    }
}

+ (void)configureNavigationControllerAppearance:(UINavigationController*)navigationController withMainColor:(UIColor*)mainColor andSecondaryColor:(UIColor*)secondaryColor
{
    [OTAppConfiguration configureApplicationAppearance];
    
    UINavigationBar.appearance.backgroundColor = mainColor;
    UINavigationBar.appearance.barTintColor = mainColor;
    UINavigationBar.appearance.tintColor = secondaryColor;
    
    navigationController.automaticallyAdjustsScrollViewInsets = NO;
    
    UINavigationBar *navigationBar = navigationController.navigationBar;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [UINavigationBarAppearance new];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.backgroundColor = mainColor;
        NSDictionary *textAttributes = @{
            NSForegroundColorAttributeName: [UIColor appGreyishBrownColor]
        };
        navBarAppearance.titleTextAttributes = textAttributes;
        navBarAppearance.largeTitleTextAttributes = textAttributes;
        navigationBar.standardAppearance = navBarAppearance;
        navigationBar.scrollEdgeAppearance = navBarAppearance;
    } else
    #endif
    {
        navigationBar.backgroundColor = mainColor;
        navigationBar.tintColor = secondaryColor;
        navigationBar.barTintColor = mainColor;
    }
}

#pragma mark - Push notifications

+ (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [OTPushNotificationsService applicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

+ (void)applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [OTPushNotificationsService applicationDidFailToRegisterForRemoteNotificationsWithError:error];
    
    NSLog(@"Push registration failure : %@", [error localizedDescription]);
}

+ (void)applicationDidRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [OTPushNotificationsService legacyAuthorizationRequestCompletedWithError:nil];
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    UIApplicationState state = [application applicationState];
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    [pnService handleRemoteNotification:userInfo applicationState:state];
    completionHandler(UIBackgroundFetchResultNewData);
}

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    UIApplicationState state = [application applicationState];
    
    if (state == UIApplicationStateActive ||
        state == UIApplicationStateBackground ||
        state == UIApplicationStateInactive) {
        OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
        [pnService handleLocalNotification:userInfo applicationState:state];
    }
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    
    if ([pnService isMixpanelDeepLinkNotification:userInfo]) {
        //for mixpanel deeplinks, shows the push notification
        completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
    } else {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        [pnService handleRemoteNotification:userInfo applicationState:state];
    }
}

#pragma mark - Firebase Messaging

+ (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    
}

#pragma - Appearance

+ (UIImage *)tabSelectionIndicatorImage:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [color setFill];
    CGFloat marginOffset = 5;
    
    UIRectFill(CGRectMake(marginOffset, 0, size.width - 2*marginOffset, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Application features/options

+ (NSInteger)applicationType
{
    return [OTAppConfiguration sharedInstance].environmentConfiguration.applicationType;
}
    
+ (BOOL)isApplicationTypeEntourage
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeEntourage) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)supportsTourFunctionality
{
    return YES;
}

+ (BOOL)supportsSolidarityGuideFunctionality
{
    return YES;
}

+ (BOOL)supportsFacebookIntegration
{
    return YES;
}

+ (BOOL)supportsProfileEditing {
    return YES;
}

+ (BOOL)shouldShowIntroTutorial:(OTUser*)user
{
    return NO;//Bypass intro for now
   // return !user.isAnonymous;
}

+ (BOOL)shouldShowAddEventDisclaimer
{
    return YES;
}

+ (BOOL)shouldAllowLoginFromWelcomeScreen
{
    return YES;
}

+ (BOOL)shouldAlwaysRequestUserToUploadPicture
{
    return YES;
}

+ (BOOL)shouldAlwaysRequestUserToAddActionZone
{
    return NO;
}

+ (BOOL)shouldAlwaysRequestUserLocation
{
    return IS_PRO_USER ? NO : YES;
}

+ (BOOL)shouldHideFeedsAndMap
{
    return NO;
}

+ (BOOL)supportsAddingActionsFromMap
{
    return YES;
}
    
+ (BOOL)supportsAddingActionsFromMapOnLongPress {
    return YES;
}

+ (BOOL)shouldShowNumberOfUserActionsSection:(OTUser*)user
{
    return [user.type isEqualToString:USER_TYPE_PRO];
}

+ (BOOL)shouldAutoLaunchEditorOnAddAction
{
    return NO;
}

+ (BOOL)shouldShowCreatorImagesForNewsFeedItems {
    return YES;
}

+ (BOOL)shouldShowNumberOfUserAssociationsSection:(OTUser*)user
{
    return ((user.organization && [user.type isEqualToString:USER_TYPE_PRO]) || user.partner);
}

+ (BOOL)shouldShowNumberOfUserPrivateCirclesSection:(OTUser*)user
{
    return NO;
}

+ (BOOL)shouldShowMapHeatzoneForEntourage:(OTEntourage*)entourage {
    if ([entourage isOuting]) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldShowAssociationsOnUserProfile {
    return YES;
}

+ (BOOL)shouldShowPOIsOnFeedsMap {
    return NO;
}

+ (BOOL)supportsClosingFeedAction:(OTFeedItem*)item {
    return YES;
}

+ (BOOL)supportsFilteringEvents {
    return YES;
}

+ (BOOL)shouldShowEntouragePrivacyDisclaimerOnCreation:(OTEntourage*)entourage {
    if ([entourage isOuting]) {
        return YES;
    }
    
    return NO;
}

+ (NSString*)iTunesAppId {
    return @"1072244410";
}

+ (BOOL)shouldAskForConsentWhenCreatingEntourage:(OTEntourage*)entourage {
    if ([entourage isOuting] ||
        [entourage isContribution]) {
        return NO;
    }
    
    return [entourage isAskForHelp];
}

+ (BOOL)shouldAskForConfidentialityWhenCreatingEntourage:(OTEntourage*)entourage {
    return NO;
}

+ (NSDictionary *)community {
    return self.sharedInstance.environmentConfiguration.community;
}

@end
