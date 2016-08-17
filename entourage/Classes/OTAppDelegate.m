//
//  OTAppDelegate.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"

// Controllers
#import "OTMessageViewController.h"
#import "OTLoginViewController.h"
#import "OTStartupViewController.h"
#import "SWRevealViewController.h"
#import "OTActiveFeedItemViewController.h"

// Pods
#import "SimpleKeychain.h"
#import "AFNetworkActivityLogger.h"
#import "SVProgressHUD.h"

// Service
#import "OTAuthService.h"
#import "OTTourService.h"
#import "OTEntourageService.h"

// Util
#import "OTConsts.h"
#import "IQKeyboardManager.h"
#import "UIStoryboard+entourage.h"
#import "UIStoryboard+entourage.h"
#import "OTMainViewController.h"
#import "OTLocationManager.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"
#import "NSDictionary+Parsing.h"

#import "OTPictureUploadService.h"
#import "OTDeepLinkService.h"
#import "OTFeedItemFactory.h"

#define APNOTIFICATION_CHAT_MESSAGE "NEW_CHAT_MESSAGE"
#define APNOTIFICATION_JOIN_REQUEST "NEW_JOIN_REQUEST"
#define APNOTIFICATION_REQUEST_ACCEPTED "JOIN_REQUEST_ACCEPTED"

#pragma mark - OTAppDelegate

const CGFloat OTNavigationBarDefaultFontSize = 17.f;

NSString *const kUserInfoSender = @"sender";
NSString *const kUserInfoObject = @"object";
NSString *const kUserInfoMessage = @"content";
NSString *const kUserInfoExtraMessage = @"extra";
NSString *const kAPNType = @"type";
NSString *const kLoginFailureNotification = @"loginFailureNotification";

@interface OTAppDelegate () <UIApplicationDelegate>

@property (nonatomic) BOOL shouldShowNotificationAlert;
@property (nonatomic) BOOL shouldShowLocalNotificationAlert;

@end

@implementation OTAppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //logger
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"EMA.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    
	[Flurry setCrashReportingEnabled:YES];
	[Flurry startSession:OTLocalizedString(@"FLURRY_API_KEY")];
    [IQKeyboardManager sharedManager].enable = YES;
    [self configureUIAppearance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToLogin:) name:[kLoginFailureNotification copy] object:nil];
    
    if ([NSUserDefaults standardUserDefaults].currentUser) {
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
    
    if ([[NSUserDefaults standardUserDefaults] currentUser].token)
        [[OTAuthService new] sendAppInfoWithSuccess:^() {
            NSLog(@"Application info sent!");
        }
        failure:^(NSError * error) {
            NSLog(@"ApplicationsERR: %@", error.description);
        }];
    [OTPictureUploadService configure];
    
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"APP WILL TERMINATE.");
}

#pragma mark - Private methods

- (void)popToLogin:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] setCurrentUser:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDisclaimer];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPhone];
    [[A0SimpleKeychain keychain] deleteEntryForKey:kKeychainPassword];
    
    [UIStoryboard showStartup];
}

#pragma mark - Configure push notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSDictionary* notificationInfo = @{ kNotificationPushStatusChangedStatusKey: [NSNumber numberWithBool:YES] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushStatusChanged object:nil userInfo:notificationInfo];

    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Push registration success with token : %@", token);
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[OTAuthService new] sendAppInfoWithSuccess:^{
        NSLog(@"Application info sent!");
    } failure:^(NSError *error) {
        NSLog(@"ApplicationsERR: %@", error.description);
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Push registration failure : %@", [error localizedDescription]);
    NSDictionary* notificationInfo = @{ kNotificationPushStatusChangedStatusKey: [NSNumber numberWithBool:NO] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushStatusChanged object:nil userInfo:notificationInfo];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Push notification received: %@", userInfo);
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground ||  state == UIApplicationStateInactive) {
        self.shouldShowNotificationAlert =  YES;
        NSDictionary *apnContent = [userInfo objectForKey:kUserInfoMessage];
        NSDictionary *apnExtra = [apnContent objectForKey:kUserInfoExtraMessage];
        NSString *apnType = [apnExtra valueForKey:kAPNType];
        NSNumber *joinableId = [apnExtra numberForKey:@"joinable_id"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[userInfo objectForKey:kUserInfoSender] message:[userInfo objectForKey:kUserInfoObject] preferredStyle:UIAlertControllerStyleAlert];
        if ([apnType isEqualToString:@APNOTIFICATION_JOIN_REQUEST])
            [self handleJoinRequestNotification:userInfo showingAlert:alert];
        else {
            if ([apnType isEqualToString:@APNOTIFICATION_CHAT_MESSAGE])
                [self handleChatNotification:userInfo showingAlert:alert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:defaultAction];
        }
        
        UIViewController *rootVC = application.keyWindow.rootViewController;
        if (rootVC.presentedViewController) {
            if ([rootVC.presentedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navC = (UINavigationController*)rootVC.presentedViewController;
                UIViewController *topVC = navC.viewControllers.firstObject;
                if ([topVC isKindOfClass:[OTActiveFeedItemViewController class]]) {
                    OTActiveFeedItemViewController *feedItemVC = (OTActiveFeedItemViewController*)topVC;
                    if (feedItemVC.feedItem.uid.intValue == joinableId.intValue) {
                        self.shouldShowNotificationAlert = NO;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationNewMessage object:nil userInfo:apnContent];
                    }
                }
            }
            if (self.shouldShowNotificationAlert)
                [rootVC.presentedViewController presentViewController:alert animated:YES completion:nil];
        } else
            [rootVC presentViewController:alert animated:YES completion:nil];
        
        //Refreshing the newsfeed when a push notification is received
        if ([rootVC isKindOfClass:[SWRevealViewController class]]) {
            SWRevealViewController *revealController = (SWRevealViewController*)rootVC;
            if ([[revealController frontViewController] isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navController = (UINavigationController*)[revealController frontViewController];
                if ([navController.topViewController isKindOfClass:[OTMainViewController class]]) {
                    OTMainViewController *mainController = (OTMainViewController*)navController.topViewController;
                    [mainController getData];
                }
            }
        }
    }
    application.applicationIconBadgeNumber = 0;
}

- (void)handleJoinRequestNotification:(NSDictionary *)notificationDictionary showingAlert:(UIAlertController*)alert
{
    NSDictionary *apnContent = [notificationDictionary objectForKey:kUserInfoMessage];
    NSDictionary *apnExtra = [apnContent objectForKey:kUserInfoExtraMessage];
    
    OTFeedItemJoiner *joiner = [OTFeedItemJoiner fromPushNotifiationsData:apnExtra];
    
    NSString *feedItemType = [apnExtra valueForKey:@"joinable_type"];
    NSNumber *feedItemId = [apnExtra numberForKey:@"joinable_id"];

    UIAlertAction *refuseJoinRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"refuseAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[[OTFeedItemFactory createForType:feedItemType andId:feedItemId] getJoiner] reject:joiner success:nil failure:nil];
    }];
    UIAlertAction *acceptJoinRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"acceptAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[[OTFeedItemFactory createForType:feedItemType andId:feedItemId] getJoiner] accept:joiner success:nil failure:nil];
    }];
    [alert addAction:refuseJoinRequestAction];
    [alert addAction:acceptJoinRequestAction];
}

- (void)handleChatNotification:(NSDictionary *)notificationDictionary showingAlert:(UIAlertController*)alert
{
    NSDictionary *apnContent = [notificationDictionary objectForKey:kUserInfoMessage];
    NSDictionary *apnExtra = [apnContent objectForKey:kUserInfoExtraMessage];
    
    NSNumber *joinableId = [apnExtra numberForKey:@"joinable_id"];
    NSString *type = [apnExtra valueForKey:@"joinable_type"];
    
    UIAlertAction *openAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OTDeepLinkService new] navigateTo:joinableId withType:type];
    }];
    [alert addAction:openAction];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"Local notification received: %@", userInfo);
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground ||  state == UIApplicationStateInactive) {
        UIApplication *app = [UIApplication sharedApplication];
        UIViewController *rootVC = app.windows.firstObject.rootViewController;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[userInfo objectForKey:kUserInfoSender] message:[userInfo objectForKey:kUserInfoObject] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"showAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [rootVC dismissViewControllerAnimated:YES completion:nil];
                if ([rootVC isKindOfClass:[SWRevealViewController class]])
                    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationLocalTourConfirmation object:nil];
                else
                    [UIStoryboard showSWRevealController];
        }];
        [alert addAction:defaultAction];
        [alert addAction:openAction];
        
        if (rootVC.presentedViewController) {
            UIViewController *presentedController = (UINavigationController*)rootVC.presentedViewController;
            if([presentedController class] == [UINavigationController class])
                if (![((UINavigationController *)presentedController).viewControllers.firstObject isKindOfClass:[OTCreateMeetingViewController class]])
                    [rootVC.presentedViewController presentViewController:alert animated:YES completion:nil];
        } else
            [rootVC presentViewController:alert animated:YES completion:nil];
    }
    application.applicationIconBadgeNumber = 0;
}

#pragma mark - Configure UIAppearance

- (void)configureUIAppearance {
	// UIStatusBar
	UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;

	// UINavigationBar
    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
    UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];

	UIFont *navigationBarFont = [UIFont systemFontOfSize:OTNavigationBarDefaultFontSize weight:UIFontWeightRegular];
	UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor grayColor] };
	[UIBarButtonItem.appearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
	                                                      NSFontAttributeName : navigationBarFont } forState:UIControlStateNormal];
}

@end