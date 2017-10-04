//
//  OTAppDelegate.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"
#import "OTUser.h"
#import "A0SimpleKeychain.h"
#import "OTConsts.h"
#import "IQKeyboardManager.h"
#import "NSUserDefaults+OT.h"
#import "UIStoryboard+entourage.h"
#import "OTLocationManager.h"
#import "OTPushNotificationsService.h"
#import "OTPictureUploadService.h"
#import "OTAuthService.h"
#import "OTDeepLinkService.h"
#import "OTMainViewController.h"
#import "OTOngoingTourService.h"
#import "SVProgressHUD.h"
#import "Flurry.h"
#import "OTVersionInfo.h"
#import "OTDebugLog.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "entourage-Swift.h"
#import "UIColor+entourage.h"
#import "OTUnreadMessagesService.h"
#import "OTLoginViewController.h"
#import "OTLostCodeViewController.h"
#import "OTPhoneViewController.h"
#import "OTCodeViewController.h"
#import "Mixpanel/Mixpanel.h"


const CGFloat OTNavigationBarDefaultFontSize = 17.f;
NSString *const kLoginFailureNotification = @"loginFailureNotification";
NSString *const kUpdateBadgeCountNotification = @"updateBadgeCountNotification";

@interface OTAppDelegate () <UIApplicationDelegate>

@property (nonatomic, strong) OTPushNotificationsService *pnService;
@property (nonatomic, assign) BOOL launchedFromNotifications;

@end

@implementation OTAppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[OTDebugLog sharedInstance] setConsoleOutput];

#if !DEBUG
    [Fabric with:@[[Crashlytics class]]];
    [Flurry setBackgroundSessionEnabled:NO];
    FlurrySessionBuilder *builder = [[[[FlurrySessionBuilder new] withLogLevel:FlurryLogLevelAll] withCrashReporting:YES] withAppVersion:[OTVersionInfo currentVersion]];
    [Flurry startSession:[ConfigurationManager shared].flurryAPIKey withSessionBuilder:builder];
#endif
    NSString *mixpanelToken = [ConfigurationManager shared].MixpanelToken;
    [Mixpanel sharedInstanceWithToken:mixpanelToken];
    [Mixpanel sharedInstance].enableLogging = YES;
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [self configureUIAppearance];
    
    self.pnService = [OTPushNotificationsService new];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToLogin:) name:[kLoginFailureNotification copy] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge) name:[kUpdateBadgeCountNotification copy] object:nil];
    
    if ([NSUserDefaults standardUserDefaults].currentUser) {
        if([NSUserDefaults standardUserDefaults].isTutorialCompleted) {
            [[OTLocationManager sharedInstance] startLocationUpdates];
            NSDictionary *pnData = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if(pnData)
                [self.pnService handleAppLaunchFromNotificationCenter:pnData];
        }
        else
            [UIStoryboard showUserProfileDetails];
    }
    else
    {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [UIStoryboard showStartup];
    }
    
    [OTPictureUploadService configure];
	return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    if ([NSUserDefaults standardUserDefaults].currentUser)
//        [[OTLocationManager sharedInstance] startLocationUpdates];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if([OTOngoingTourService sharedInstance].isOngoing)
        return;
    [[OTLocationManager sharedInstance] stopLocationUpdates];
}

#pragma mark - Private methods

- (void)popToLogin:(NSNotification *)notification {
    [SVProgressHUD show];
    [self.pnService clearTokenWithSuccess:^() {
        [SVProgressHUD dismiss];
        [self clearUserData];
    } orFailure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self clearUserData];
    }];
}

- (void)updateBadge {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[OTUnreadMessagesService new] totalCount].integerValue];
}

- (void)clearUserData {
    [[NSUserDefaults standardUserDefaults] setCurrentUser:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPhone];
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPassword];

    [UIStoryboard showStartup];
}

#pragma mark - Configure push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSDictionary* notificationInfo = @{ kNotificationPushStatusChangedStatusKey: [NSNumber numberWithBool:YES] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushStatusChanged object:nil userInfo:notificationInfo];
    [self.pnService saveToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Push registration failure : %@", [error localizedDescription]);
    NSDictionary* notificationInfo = @{ kNotificationPushStatusChangedStatusKey: [NSNumber numberWithBool:NO] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushStatusChanged object:nil userInfo:notificationInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground ||  state == UIApplicationStateInactive)
        [self.pnService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        [self.pnService handleLocalNotification:userInfo];
}

#pragma mark - Configure UIAppearance

- (void)configureUIAppearance {
	UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
    UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];
	UIFont *navigationBarFont = [UIFont systemFontOfSize:OTNavigationBarDefaultFontSize weight:UIFontWeightRegular];
	UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor grayColor] };
	[UIBarButtonItem.appearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : navigationBarFont } forState:UIControlStateNormal];

    UIPageControl.appearance.backgroundColor = [UIColor whiteColor];
    UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor appGreyishBrownColor];
    
#if BETA
    UINavigationBar.appearance.barTintColor = [UIColor redColor];
    UINavigationBar.appearance.backgroundColor = [UIColor redColor];
#endif
}

@end
