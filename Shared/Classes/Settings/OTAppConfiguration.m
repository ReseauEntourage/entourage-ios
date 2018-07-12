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
    
    tabBarController.viewControllers = @[mainMapNavController, messagesNavController, menuNavController];
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        tabBarController.selectedIndex = 1;
    }
    
    // Add top shadow above tab bar
    tabBarController.tabBar.layer.shadowOffset = CGSizeMake(0, 0);
    tabBarController.tabBar.layer.shadowRadius = 3;
    tabBarController.tabBar.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    tabBarController.tabBar.layer.shadowOpacity = 0.3;

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
    //UITabBar.appearance.backgroundColor = [[ApplicationTheme shared] backgroundThemeColor];
    UITabBar.appearance.tintColor = [[ApplicationTheme shared] backgroundThemeColor];
    UITabBar.appearance.barTintColor = [[ApplicationTheme shared] backgroundThemeColor];
    UITabBar.appearance.translucent = NO;
    
    UITabBar *currentTabBar = tabBarController.tabBar;
    CGSize size = CGSizeMake(currentTabBar.frame.size.width / currentTabBar.items.count, currentTabBar.frame.size.height);
    currentTabBar.selectionIndicatorImage = [OTAppConfiguration tabSelectionIndicatorImage:[UIColor whiteColor] size:size];
}

+ (void)configureNavigationControllerAppearance:(UINavigationController*)navigationController
{
    navigationController.automaticallyAdjustsScrollViewInsets = NO;
    navigationController.navigationBar.backgroundColor = [[ApplicationTheme shared] primaryNavigationBarTintColor];
    navigationController.navigationBar.tintColor = [[ApplicationTheme shared] secondaryNavigationBarTintColor];
    navigationController.navigationBar.barTintColor = [[ApplicationTheme shared] primaryNavigationBarTintColor];
    
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
    
    UITabBarController *tabBarController = (UITabBarController*)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (tabBarController.tabBar) {
        UITabBar *currentTabBar = tabBarController.tabBar;
        for (UITabBarItem *item in currentTabBar.items) {
            [item setTitleTextAttributes:normalTextAttributes forState:UIControlStateNormal];
        }
        [currentTabBar.selectedItem setTitleTextAttributes:selectionTextAttributes forState:UIControlStateNormal];
    }
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

+ (NSInteger)applicationType
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

+ (BOOL)isGeolocationMandatory {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)shouldShowIntroTutorial
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return NO;
    }
    
    // EMA-1991
    return NO;
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

@end
