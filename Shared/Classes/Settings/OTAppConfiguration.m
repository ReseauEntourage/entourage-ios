//
//  OTAppConfiguration.m
//  entourage
//
//  Created by Smart Care on 17/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTAppConfiguration.h"
#import "OTDeepLinkService.h"
#import "OTPushNotificationsData.h"
#import "OTVersionInfo.h"
#import "OTDeepLinkService.h"
#import "FBSDKCoreKit.h"
#import "OTLocationManager.h"
#import "OTUser.h"
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
#import "UIColor+entourage.h"
#import "OTUnreadMessagesService.h"
#import "OTLoginViewController.h"
#import "OTLostCodeViewController.h"
#import "OTPhoneViewController.h"
#import "OTCodeViewController.h"
#import "OTAppDelegate.h"
#import "A0SimpleKeychain.h"
#import "UIStoryboard+entourage.h"
#import "OTMenuViewController.h"
#import "OTAppState.h"
#import "OTMyEntouragesViewController.h"
#import "entourage-Swift.h"

@import Firebase;

const CGFloat OTNavigationBarDefaultFontSize = 17.f;

@interface OTAppConfiguration ()
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

    [[OTDebugLog sharedInstance] setConsoleOutput];
    
#if !DEBUG
    [self configureCrashReporting];
    [self configureFirebase];
#endif
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
    [self configurePushNotifcations];
    [self configureAnalyticsWithOptions:launchOptions];
    [self configurePhotoUploadingService];
    
    [OTAppConfiguration configureApplicationAppearance];
    [OTAppState launchApplicatioWithOptions:launchOptions];
    
    return YES;
}

- (void)popToLogin {
    [OTAppState returnToLogin];
}

- (void)updateBadge: (NSNotification *) notification {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[OTUnreadMessagesService new] totalCount].integerValue];
}

+ (void)clearUserData {
    [[NSUserDefaults standardUserDefaults] setCurrentUser:nil];
    [[NSUserDefaults standardUserDefaults] setCurrentOngoingTour:nil];
    [[NSUserDefaults standardUserDefaults] setTourPoints:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPhone];
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPassword];
}

#pragma mark - Application State

+ (void)applicationDidBecomeActive:(UIApplication *)application {
    // Call the 'activateApp' method to log an app event for use
    // in analytics and advertising reporting.
    [FBSDKAppEvents activateApp];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                [mixpanel.people set:@{@"EntourageNotifEnable": @"YES"}];
                [FIRAnalytics setUserPropertyString:@"YES" forName:@"EntourageGeolocEnable"];
            }
            else {
                [mixpanel.people set:@{@"EntourageNotifEnable": @"NO"}];
                [FIRAnalytics setUserPropertyString:@"NO" forName:@"EntourageGeolocEnable"];
            }
        }];
    }
}

+ (void)applicationWillEnterForeground:(UIApplication *)application {
    
    if ([NSUserDefaults standardUserDefaults].currentUser) {
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
        [[OTDeepLinkService new] navigateTo:pnData.joinableId withType:pnData.joinableType];
    }
}

+ (BOOL)handleApplication:(UIApplication *)application openURL:(NSURL *)url
{
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.runsOnStaging) {
        
        if ([[url scheme] isEqualToString:@"entourage-preprod"] ||
            [[url scheme] isEqualToString:@"pfp-preprod"]) {
            [[OTDeepLinkService new] handleDeepLink:url];
            return YES;
        }
    } else {
        if ([[url scheme] isEqualToString:@"entourage"] ||
            [[url scheme] isEqualToString:@"pfp-prod"]) {
            [[OTDeepLinkService new] handleDeepLink:url];
            return YES;
        }
    }

    return NO;
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        //NSArray *arrayWithStrings = [url.absoluteString componentsSeparatedByString:@"/"];
        //NSString *entourageId = arrayWithStrings.lastObject;
        //[[OTDeepLinkService new] navigateTo:entourageId];
        [[OTDeepLinkService new] handleUniversalLink:url];
    }
    return true;
}

#pragma mark - App Configurations

- (void)configurePushNotifcations
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToLogin) name:[kLoginFailureNotification copy] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge:) name:[kUpdateBadgeCountNotification copy] object:nil];
}

- (void)configurePhotoUploadingService {
    [OTPictureUploadService configure];
}

- (void)configureCrashReporting
{
    [Fabric with:@[[Crashlytics class]]];
}

- (void)configureFirebase
{
    NSString *firebaseConfigFileName = nil;
    
    switch ([OTAppConfiguration applicationType]) {
        case ApplicationTypeVoisinAge:
            firebaseConfigFileName = [self.environmentConfiguration runsOnStaging] ?
            @"GoogleService-Info-social.entourage.pfpios.beta" :
            @"GoogleService-Info-social.entourage.pfpios";
            break;
            
        default:
            firebaseConfigFileName = [self.environmentConfiguration runsOnStaging] ?
            @"GoogleService-Info-social.entourage.ios.beta" :
            @"GoogleService-Info";
            break;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:firebaseConfigFileName ofType:@"plist"];
    FIROptions *options = [[FIROptions alloc] initWithContentsOfFile:filePath];
    
    if (options) {
        [FIRApp configureWithOptions:options];
    }
}

- (void)configureAnalyticsWithOptions:(NSDictionary *)launchOptions
{
    NSString *mixpanelToken = self.environmentConfiguration.MixpanelToken;
    
    [Mixpanel sharedInstanceWithToken:mixpanelToken launchOptions:launchOptions];
    [Mixpanel sharedInstance].enableLogging = YES;
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    mixpanel.minimumSessionDuration = 0;
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser) {
        [[OTAuthService new] getDetailsForUser:currentUser.sid success:^(OTUser *user) {
            [NSUserDefaults standardUserDefaults].currentUser = user;
            [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:^(NSError *error) {
            NSLog(@"@fails getting user %@", error.description);
        }];
        
        [OTLogger setupMixpanelWithUser:currentUser];
        [[OTAuthService new] sendAppInfoWithSuccess:nil failure:nil];
    }
}

+ (UITabBarController*)configureMainTabBar
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    
    UIFont *selectedTabBarFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary *selectionTextAttributes = @{NSForegroundColorAttributeName:[[ApplicationTheme shared] backgroundThemeColor],
                                              NSFontAttributeName:selectedTabBarFont};
    // Menu tab
    id menuViewController;
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        menuViewController = [[OTPfpMenuViewController alloc] init];
    }
    else {
        menuViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"OTMenuViewControllerIdentifier"];
    }
    UINavigationController *menuNavController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
    menuNavController.tabBarItem.title = @"menu";
    menuNavController.tabBarItem.image = [UIImage imageNamed:@"menu"];
    [menuNavController.tabBarItem setTitleTextAttributes:selectionTextAttributes forState:UIControlStateSelected];
    
    // Proximity Map Tab
    OTMainViewController *mainMapViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"OTMain"];
    UINavigationController *mainMapNavController = [[UINavigationController alloc] initWithRootViewController:mainMapViewController];
    mainMapNavController.tabBarItem.title = @"à proximité";
    mainMapNavController.tabBarItem.image = [UIImage imageNamed:@"guide"];
    
    // Messages Tab
    OTMyEntouragesViewController *messagesViewController = [[UIStoryboard myEntouragesStoryboard] instantiateViewControllerWithIdentifier:@"OTMyEntouragesViewController"];
    UINavigationController *messagesNavController = [[UINavigationController alloc] initWithRootViewController:messagesViewController];
    messagesNavController.tabBarItem.title = @"messagerie";
    messagesNavController.tabBarItem.image = [UIImage imageNamed:@"discussion"];
    
    NSArray *controllers = @[];
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeEntourage) {
        controllers = @[mainMapNavController, messagesNavController, menuNavController];
    } else {
        controllers = @[menuNavController, messagesNavController, mainMapNavController];
    }
    
    tabBarController.viewControllers = controllers;
    
    [OTAppConfiguration configureTabBarAppearance:tabBarController];

    return tabBarController;
}

+ (void)configureApplicationAppearance
{
    UIColor *primaryNavigationBarTintColor = [UIColor whiteColor];
    UIColor *secondaryNavigationBarTintColor = [UIColor appOrangeColor];
    UIColor *backgroundThemeColor = [UIColor appOrangeColor];
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        backgroundThemeColor = [UIColor pfpBlueColor];
        secondaryNavigationBarTintColor = [UIColor pfpBlueColor];
    }
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.runsOnStaging) {
        primaryNavigationBarTintColor = [UIColor redColor];
    }
    
    [[ApplicationTheme shared] setPrimaryNavigationBarTintColor:primaryNavigationBarTintColor];
    [[ApplicationTheme shared] setSecondaryNavigationBarTintColor:secondaryNavigationBarTintColor];
    [[ApplicationTheme shared] setBackgroundThemeColor:backgroundThemeColor];
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    UINavigationBar.appearance.barTintColor = secondaryNavigationBarTintColor;
    UINavigationBar.appearance.backgroundColor = secondaryNavigationBarTintColor;
    UINavigationBar.appearance.tintColor = primaryNavigationBarTintColor;
    
    UIFont *navigationBarFont = [UIFont systemFontOfSize:OTNavigationBarDefaultFontSize weight:UIFontWeightRegular];
    UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    [UIBarButtonItem.appearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
                                                          NSFontAttributeName : navigationBarFont } forState:UIControlStateNormal];
    
    UIPageControl.appearance.backgroundColor = [UIColor whiteColor];
    UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor appGreyishBrownColor];
}

+ (void)configureTabBarAppearance:(UITabBarController*)tabBarController
{
    UITabBar.appearance.backgroundColor = [[ApplicationTheme shared] backgroundThemeColor];
    UITabBar.appearance.tintColor = [[ApplicationTheme shared] backgroundThemeColor];
    UITabBar.appearance.barTintColor = [[ApplicationTheme shared] backgroundThemeColor];
    
    UITabBar *currentTabBar = tabBarController.tabBar;
    CGSize size = CGSizeMake(currentTabBar.frame.size.width / currentTabBar.items.count, currentTabBar.frame.size.height);
    currentTabBar.selectionIndicatorImage = [OTAppConfiguration tabSelectionIndicatorImage:[UIColor whiteColor] size:size];
    currentTabBar.unselectedItemTintColor = [UIColor whiteColor];
    
    UIFont *selectedTabBarFont = [UIFont boldSystemFontOfSize:12];
    NSDictionary *selectionTextAttributes = @{NSForegroundColorAttributeName:[[ApplicationTheme shared] backgroundThemeColor],
                                              NSFontAttributeName:selectedTabBarFont};
    
    [UITabBarItem.appearance setTitleTextAttributes:selectionTextAttributes forState:UIControlStateSelected];
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                      NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                           forState:UIControlStateNormal];
}

#pragma mark - Push notifications

+ (void)applicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    NSDictionary* notificationInfo = @{ kNotificationPushStatusChangedStatusKey: [NSNumber numberWithBool:YES] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushStatusChanged object:nil userInfo:notificationInfo];
    @try {
        [pnService saveToken:deviceToken];
    }
    @catch (NSException *ex) {
        
    }
}

+ (void)applicationDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Push registration failure : %@", [error localizedDescription]);
    NSDictionary* notificationInfo = @{ kNotificationPushStatusChangedStatusKey: [NSNumber numberWithBool:NO] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushStatusChanged object:nil userInfo:notificationInfo];
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    UIApplicationState state = [application applicationState];
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground ||  state == UIApplicationStateInactive) {
        [pnService handleRemoteNotification:userInfo];
    }
}

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    UIApplicationState state = [application applicationState];
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
        [pnService handleLocalNotification:userInfo];
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
        [pnService handleRemoteNotification:userInfo];
    }
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

+ (ApplicationType)applicationType
{
    return [OTAppConfiguration sharedInstance].environmentConfiguration.applicationType;
}

+ (BOOL)supportsTourFunctionality
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)supportsSolidarityGuideFunctionality
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isGeolocationMandatory {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isMVP {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)shouldShowIntroTutorial
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    return YES;
}

+ (BOOL)shouldAllowLoginFromWelcomeScreen
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldAlwaysRequestUserToUploadPicture
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (NSString*)aboutUrlString
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return PFP_ABOUT_CGU_URL;
    }
    return ABOUT_CGU_URL;
}

+ (NSString *)welcomeDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_welcomeText");
    }
    
    return OTLocalizedString(@"welcomeText");
}

+ (UIImage*)welcomeLogo
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return nil;
    }
    
    return [UIImage imageNamed:@"logoWhiteEntourage"];
}

+ (NSString *)userProfileNameDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_userNameDescriptionText");
    }
    
    return OTLocalizedString(@"userNameDescriptionText");
}

+ (NSString *)userProfileEmailDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_userEmailDescriptionText");
    }
    
    return OTLocalizedString(@"userEmailDescriptionText");
}

+ (NSString *)notificationsRightsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_userNotificationsDescriptionText");
    }
    
    return OTLocalizedString(@"userNotificationsDescriptionText");
}

+ (NSString *)geolocalisationRightsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_geolocalisationDescriptionText");
    }
    
    return OTLocalizedString(@"geolocalisationDescriptionText");
}

+ (NSString *)notificationsNeedDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_notificationNeedDescription");
    }
    
    return OTLocalizedString(@"notificationNeedDescription");
}


@end
