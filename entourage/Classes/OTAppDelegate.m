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
#import "OTBadgeNumberService.h"
#import "OTVersionInfo.h"

const CGFloat OTNavigationBarDefaultFontSize = 17.f;
NSString *const kLoginFailureNotification = @"loginFailureNotification";

@interface OTAppDelegate () <UIApplicationDelegate>

@property (nonatomic, strong) OTPushNotificationsService *pnService;

@end

@implementation OTAppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //logger
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"EMA.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    
#if !DEBUG
    [Flurry setAppVersion:[OTVersionInfo currentVersion]];
	[Flurry setCrashReportingEnabled:YES];
	[Flurry startSession:OTLocalizedString(@"FLURRY_API_KEY")];
#endif
    [IQKeyboardManager sharedManager].enable = YES;
    [self configureUIAppearance];
    
    self.pnService = [OTPushNotificationsService new];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToLogin:) name:[kLoginFailureNotification copy] object:nil];
    
    if ([NSUserDefaults standardUserDefaults].currentUser) {
        [self.pnService promptUserForPushNotifications];
        if([NSUserDefaults standardUserDefaults].isTutorialCompleted)
            [[OTLocationManager sharedInstance] startLocationUpdates];
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
    if ([NSUserDefaults standardUserDefaults].currentUser)
        [[OTLocationManager sharedInstance] startLocationUpdates];
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

- (void)clearUserData {
    [[OTBadgeNumberService sharedInstance] clearData];
    [[NSUserDefaults standardUserDefaults] setCurrentUser:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@DEVICE_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kEncounterDisclaimer];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kEntourageDisclaimer];
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
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground ||  state == UIApplicationStateInactive)
        [self.pnService handleLocalNotification:userInfo];
    application.applicationIconBadgeNumber = 0;
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
}

@end
