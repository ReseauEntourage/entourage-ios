//
//  OTAppConfiguration.m
//  entourage
//
//  Created by Smart Care on 17/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <IQKeyboardManager/IQKeyboardManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SimpleKeychain/A0SimpleKeychain.h>

#import "OTAppConfiguration.h"
#import "OTDeepLinkService.h"
#import "OTPushNotificationsData.h"
#import "OTVersionInfo.h"
#import "OTDeepLinkService.h"
#import "OTLocationManager.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "UIStoryboard+entourage.h"
#import "OTPushNotificationsService.h"
#import "OTPictureUploadService.h"
#import "OTAuthService.h"
#import "OTDeepLinkService.h"
#import "OTMainViewController.h"
#import "OTOngoingTourService.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIColor+entourage.h"
#import "OTUnreadMessagesService.h"
#import "OTLoginViewController.h"
#import "OTLostCodeViewController.h"
#import "OTPhoneViewController.h"
#import "OTCodeViewController.h"
#import "OTAppDelegate.h"
#import "UIStoryboard+entourage.h"
#import "OTMenuViewController.h"
#import "OTAppState.h"
#import "OTMyEntouragesViewController.h"
#import "UIImage+processing.h"
#import "OTAPIConsts.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GooglePlaces/GMSPlacesClient.h>
#import "OTMainTabBarAnonymousBehavior.h"
#import "OTAnalyticsObserver.h"
#import <FirebaseInAppMessaging/FirebaseInAppMessaging.h>
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
    
#if !DEBUG
    [self configureCrashReporting];
#endif

    [self configureFirebase];
    [OTAnalyticsObserver init];
    
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

    [OTPushNotificationsService refreshPushTokenIfConfigurationChanged];
    
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                [mixpanel.people set:@{@"EntourageNotifEnable": @"YES"}];
                [FIRAnalytics setUserPropertyString:@"YES" forName:@"EntourageNotifEnable"];
            }
            else {
                [mixpanel.people set:@{@"EntourageNotifEnable": @"NO"}];
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
    [Fabric with:@[[Crashlytics class]]];
}

- (void)configureGooglePlacesClient {
    [GMSPlacesClient provideAPIKey:[self.environmentConfiguration GooglePlaceApiKey]];
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
    
    if (!options) return;
    
    [[FIRConfiguration sharedInstance] setLoggerLevel:FIRLoggerLevelDebug];
    [FIRApp configureWithOptions:options];
    [FIRAnalytics setUserPropertyString:[OTAuthService currentUserAuthenticationLevel]
                                forName:@"AuthenticationLevel"];
    [FIRMessaging messaging].delegate = (id<FIRMessagingDelegate>)[UIApplication sharedApplication].delegate;
    if ([NSUserDefaults standardUserDefaults].currentUser) {
        [FIRInAppMessaging inAppMessaging].messageDisplaySuppressed = NO;
    }
    else {
        [FIRInAppMessaging inAppMessaging].messageDisplaySuppressed = YES;
    }
}

- (void)configureAnalyticsWithOptions:(NSDictionary *)launchOptions
{
    NSString *mixpanelToken = self.environmentConfiguration.MixpanelToken;
    
    [Mixpanel sharedInstanceWithToken:mixpanelToken launchOptions:launchOptions];
    //[Mixpanel sharedInstance].enableLogging = YES;
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    mixpanel.minimumSessionDuration = 0;
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser) {
        [[OTAuthService new] getDetailsForUser:currentUser.uuid success:^(OTUser *user) {
            [NSUserDefaults standardUserDefaults].currentUser = user;
            [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:^(NSError *error) {
            NSLog(@"@fails getting user %@", error.description);
        }];
        
        if (!currentUser.isAnonymous) {
          [OTLogger setupMixpanelWithUser:currentUser];
        }
    }
}

+ (UITabBarController*)configureMainTabBar {
    NSInteger selectedIndex = MAP_TAB_INDEX;
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        selectedIndex = MESSAGES_TAB_INDEX;
    }
    
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
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    UIStoryboard *mainStoryboard = [UIStoryboard mainStoryboard];
    
    // Menu tab
    id menuViewController;
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        menuViewController = [[OTPfpMenuViewController alloc] init];
    }
    else {
        menuViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"OTMenuViewControllerIdentifier"];
    }
    UINavigationController *menuNavController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
    menuNavController.tabBarItem.title = OTLocalizedString(@"menu");
    menuNavController.tabBarItem.image = [[UIImage imageNamed:@"menu_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    menuNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"menu_tab_selected"];

    // New Menu
    UIViewController *newMenu = [MenuViewController new];
    UIViewController *newMenuNC = [[UINavigationController alloc] initWithRootViewController: newMenu];
    newMenuNC.tabBarItem.title = OTLocalizedString(@"menu");
    newMenuNC.tabBarItem.image = [[UIImage imageNamed:@"menu_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    newMenuNC.tabBarItem.selectedImage = [UIImage imageNamed:@"menu_tab_selected"];
    
    // Proximity Map Tab
    OTMainViewController *mainMapViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"OTMain"];
    UINavigationController *mainMapNavController = [[UINavigationController alloc] initWithRootViewController:mainMapViewController];
    mainMapNavController.tabBarItem.title = OTLocalizedString(@"à proximité");
    mainMapNavController.tabBarItem.image = [[UIImage imageNamed:@"map_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mainMapNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"map_tab_selected"];

    // Messages Tab
    OTMyEntouragesViewController *messagesViewController = [[UIStoryboard myEntouragesStoryboard] instantiateViewControllerWithIdentifier:@"OTMyEntouragesViewController"];
    UINavigationController *messagesNavController = [[UINavigationController alloc] initWithRootViewController:messagesViewController];
    messagesNavController.tabBarItem.title = OTLocalizedString(@"messagerie");
    messagesNavController.tabBarItem.image = [[UIImage imageNamed:@"messages_tab"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    messagesNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"messages_tab_selected"];

    // Check if solidarity guide map is supported
    if (OTAppConfiguration.supportsSolidarityGuideFunctionality) {
        // Solidarity Guide Map Tab
        OTMainViewController *guideMapViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"OTMain"];
        guideMapViewController.isSolidarityGuide = YES;
        UINavigationController *guideMapNavController = [[UINavigationController alloc] initWithRootViewController:guideMapViewController];
        guideMapNavController.tabBarItem.title = OTLocalizedString(@"annuaire");
        guideMapNavController.tabBarItem.image = [[UIImage imageNamed:@"ic_navigation_guide"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        guideMapNavController.tabBarItem.selectedImage = [UIImage imageNamed:@"ic_navigation_guide"];
        
        tabBarController.viewControllers = @[mainMapNavController, guideMapNavController, messagesNavController, menuNavController, newMenuNC];
    }
    else {
        tabBarController.viewControllers = @[mainMapNavController, messagesNavController, menuNavController, newMenuNC];
    }

    tabBarController.selectedIndex = selectedIndex;
    
    // Add top shadow above tab bar
    tabBarController.tabBar.layer.shadowOffset = CGSizeMake(0, 0);
    tabBarController.tabBar.layer.shadowRadius = 3;
    tabBarController.tabBar.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    tabBarController.tabBar.layer.shadowOpacity = 0.3;

    id<UITabBarControllerDelegate> mainTabBarBehavior = nil;
    if ([NSUserDefaults standardUserDefaults].currentUser.isAnonymous) {
        mainTabBarBehavior = [OTMainTabBarAnonymousBehavior new];
        
    }

    [self sharedInstance].mainTabBarBehavior = mainTabBarBehavior;
    tabBarController.delegate = mainTabBarBehavior;

    return tabBarController;
}

+ (void)configureApplicationAppearance
{
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    UIColor *primaryNavigationBarTintColor = [UIColor appOrangeColor];
    UIColor *secondaryNavigationBarTintColor = [UIColor whiteColor];
    UIColor *backgroundThemeColor = [UIColor appOrangeColor];
    UIColor *titleColor = [UIColor appGreyishBrownColor];
    UIColor *subtitleColor = [UIColor appGreyishColor];
    UIColor *tableViewBgColor = [UIColor groupTableViewBackgroundColor];
    UIColor *addActionButtonColor = [UIColor appOrangeColor];
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        backgroundThemeColor = [UIColor pfpBlueColor];
        primaryNavigationBarTintColor = [UIColor pfpBlueColor];
        secondaryNavigationBarTintColor = [UIColor whiteColor];
        titleColor = [UIColor pfpGrayTextColor];
        tableViewBgColor = [UIColor pfpTableBackgroundColor];
        subtitleColor = [UIColor pfpSubtitleBlueColor];
        addActionButtonColor = [UIColor pfpGreenColor];
    }
    
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
    UIColor *navigationBarTextColor = [UIColor whiteColor];
    UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : navigationBarTextColor };
    [UIBarButtonItem.appearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : navigationBarTextColor,
                                                          NSFontAttributeName : navigationBarFont } forState:UIControlStateNormal];
    
    UIPageControl.appearance.backgroundColor = [UIColor whiteColor];
    UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor appGreyishBrownColor];
}

+ (void)configureTabBarAppearance:(UITabBarController*)tabBarController
{
    UITabBar.appearance.tintColor = [[ApplicationTheme shared] backgroundThemeColor];
    UITabBar.appearance.barTintColor = [[ApplicationTheme shared] backgroundThemeColor];
    UITabBar.appearance.translucent = NO;
    
    //Fix inset left right with white color tabbar
    float _insetWidth = 10;
    
    UITabBar *currentTabBar = tabBarController.tabBar;
    CGSize size = CGSizeMake((currentTabBar.frame.size.width / currentTabBar.items.count) + _insetWidth , currentTabBar.frame.size.height);
    currentTabBar.selectionIndicatorImage = [OTAppConfiguration tabSelectionIndicatorImage:[UIColor whiteColor] size:size];
    
    for (UINavigationController *navController in tabBarController.viewControllers) {
        [OTAppConfiguration configureNavigationControllerAppearance:navController];
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
            NSForegroundColorAttributeName: [[ApplicationTheme shared] secondaryNavigationBarTintColor]
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
    
    UIFont *selectedTabBarFont = [UIFont fontWithName:@"SFUIText-Bold" size:12];
    NSDictionary *selectionTextAttributes = @{NSForegroundColorAttributeName:[[ApplicationTheme shared] backgroundThemeColor],
                                              NSFontAttributeName:selectedTabBarFont};
    UIFont *regularTabBarFont = [UIFont fontWithName:@"SFUIText-Regular" size:12];
    NSDictionary *normalTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                           NSFontAttributeName:regularTabBarFont};
    
    UIViewController *topViewController = navigationController.topViewController;
    [topViewController.tabBarItem setTitleTextAttributes:selectionTextAttributes forState:UIControlStateSelected];
    [topViewController.tabBarItem setTitleTextAttributes:normalTextAttributes forState:UIControlStateNormal];

    [UITabBarItem.appearance setTitleTextAttributes:selectionTextAttributes forState:UIControlStateSelected];
    [UITabBarItem.appearance setTitleTextAttributes:normalTextAttributes forState:UIControlStateNormal];

    [UIBarItem.appearance setTitleTextAttributes:selectionTextAttributes forState:UIControlStateSelected];
    [UIBarItem.appearance setTitleTextAttributes:normalTextAttributes forState:UIControlStateNormal];
    
    id rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController*)rootController;
        
        if (tabBarController.tabBar) {
            UITabBar *currentTabBar = tabBarController.tabBar;
            for (UITabBarItem *item in currentTabBar.items) {
                [item setTitleTextAttributes:normalTextAttributes forState:UIControlStateNormal];
            }
            [currentTabBar.selectedItem setTitleTextAttributes:selectionTextAttributes forState:UIControlStateNormal];
        }
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

+ (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    
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

+ (BOOL)isApplicationTypeVoisinAge
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return YES;
    }
    
    return NO;
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

+ (BOOL)supportsFacebookIntegration
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)supportsProfileEditing {
    return YES;
}

+ (BOOL)shouldShowIntroTutorial:(OTUser*)user
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    return NO;//Bypass intro for now
   // return !user.isAnonymous;
}

+ (BOOL)shouldShowAddEventDisclaimer
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

+ (BOOL)shouldAlwaysRequestUserToAddActionZone
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)shouldAlwaysRequestUserLocation
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
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
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldShowNumberOfUserActionsSection:(OTUser*)user
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return YES;
    }
    
    return [user.type isEqualToString:USER_TYPE_PRO];
}

+ (BOOL)shouldAutoLaunchEditorOnAddAction
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)shouldShowCreatorImagesForNewsFeedItems {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldShowNumberOfUserAssociationsSection:(OTUser*)user
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return ((user.organization && [user.type isEqualToString:USER_TYPE_PRO]) || user.partner);
}

+ (BOOL)shouldShowNumberOfUserPrivateCirclesSection:(OTUser*)user
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)shouldShowMapHeatzoneForEntourage:(OTEntourage*)entourage {
    // EMA-2034
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    if ([entourage isOuting]) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldShowAssociationsOnUserProfile {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldShowPOIsOnFeedsMap {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)supportsClosingFeedAction:(OTFeedItem*)item {
    // EMA-2052, EMA-2124
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([item isPrivateCircle] || [item isConversation] || [item isNeighborhood]) {
            return NO;
        }
        
        if ([item isOuting]) {
            return YES;
        }
    }

    return YES;
}

+ (BOOL)supportsFilteringEvents {
    // EMA-2303
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldShowEntouragePrivacyDisclaimerOnCreation:(OTEntourage*)entourage {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return YES;
    }
    
    // EMA-2383
    if ([entourage isOuting]) {
        return YES;
    }
    
    return NO;
}

+ (NSString*)iTunesAppId {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return @"1388843838";
    }
    
    return @"1072244410";
}

+ (BOOL)shouldAskForConsentWhenCreatingEntourage:(OTEntourage*)entourage {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    // EMA-2378
    if ([entourage isOuting] ||
        [entourage isContribution]) {
        return NO;
    }
    
    return [entourage isAskForHelp];
}

+ (BOOL)shouldAskForConfidentialityWhenCreatingEntourage:(OTEntourage*)entourage {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    // EMA-2384
    //Plus utilisé car on affiche le choix sur la page de création.
//    if ([entourage isContribution]) {
//        return YES;
//    }
    
    return NO;
}

+ (NSDictionary *)community {
    return self.sharedInstance.environmentConfiguration.community;
}

@end
