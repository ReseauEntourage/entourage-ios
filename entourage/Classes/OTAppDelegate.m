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
#import "OTFeedItemViewController.h"
#import "SWRevealViewController.h"

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

#define APNOTIFICATION_CHAT_MESSAGE "NEW_CHAT_MESSAGE"
#define APNOTIFICATION_JOIN_REQUEST "NEW_JOIN_REQUEST"
#define APNOTIFICATION_REQUEST_ACCEPTED "JOIN_REQUEST_ACCEPTED"

/**************************************************************************************************/
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

/**************************************************************************************************/
#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //logger
    
#if DEBUGi
//#ifdef LOG2FILE
//#if TARGET_IPHONE_SIMULATOR == 0
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"EMA.log"];
    freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
#endif
//#endif
//#endif
    
    
    
    // start flurry
	[Flurry setCrashReportingEnabled:YES];
	[Flurry startSession:OTLocalizedString(@"FLURRY_API_KEY")];
    [IQKeyboardManager sharedManager].enable = YES;
      // register for push notifications
//    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
//    [application registerUserNotificationSettings:settings];
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    // configure appearence
    [self configureUIAppearance];
    
    // add notification observer for 401 error trigger
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popToLogin:)
                                                 name:[kLoginFailureNotification copy]
                                               object:nil];
    
    if ([[NSUserDefaults standardUserDefaults] currentUser])
        [[OTLocationManager sharedInstance] startLocationUpdates];
    else
    {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [UIStoryboard showStartup];
    }
    
    if ([[NSUserDefaults standardUserDefaults] currentUser].token) {
        [[OTAuthService new] sendAppInfoWithSuccess:^() {
            NSLog(@"Application info sent!");
        }
                                            failure:^(NSError * error) {
            NSLog(@"ApplicationsERR: %@", error.description);
        }];
    }
    
    //[[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    //[[AFNetworkActivityLogger sharedLogger] startLogging];
    
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"APP WILL TERMINATE.");
}

/**************************************************************************************************/
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

/**************************************************************************************************/
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


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Push notification received: %@", userInfo);
    
    // Building the notification
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground ||  state == UIApplicationStateInactive) {
        self.shouldShowNotificationAlert =  YES;
        NSDictionary *apnContent = [userInfo objectForKey:kUserInfoMessage];
        NSDictionary *apnExtra = [apnContent objectForKey:kUserInfoExtraMessage];
        NSString *apnType = [apnExtra valueForKey:kAPNType];
        NSNumber *joinableId = [apnExtra numberForKey:@"joinable_id"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[userInfo objectForKey:kUserInfoSender]
                                                                       message:[userInfo objectForKey:kUserInfoObject]
                                                                preferredStyle:UIAlertControllerStyleAlert];

        if ([apnType isEqualToString:@APNOTIFICATION_JOIN_REQUEST]) {
            [self handleJoinRequestNotification:userInfo showingAlert:alert];
        } else {
            if ([apnType isEqualToString:@APNOTIFICATION_CHAT_MESSAGE]) {
                [self handleChatNotification:userInfo showingAlert:alert];
            }
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {}];
    
            [alert addAction:defaultAction];
        }
        
        UIViewController *rootVC = application.keyWindow.rootViewController;
        if (rootVC.presentedViewController) {
            if ([rootVC.presentedViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navC = (UINavigationController*)rootVC.presentedViewController;
                UIViewController *topVC = navC.viewControllers.firstObject;
                if ([topVC isKindOfClass:[OTFeedItemViewController class]]) {
                    OTFeedItemViewController *feedItemVC = (OTFeedItemViewController*)topVC;
                    if (feedItemVC.feedItem.uid.intValue == joinableId.intValue) {
                        self.shouldShowNotificationAlert = NO;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationNewMessage object:nil userInfo:apnContent];
                    }
                }
            }
            
            if (self.shouldShowNotificationAlert)
                [rootVC.presentedViewController presentViewController:alert animated:YES completion:nil];
        } else {
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
        
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
        //End refreshing
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)handleJoinRequestNotification:(NSDictionary *)notificationDictionary
                         showingAlert:(UIAlertController*)alert
{
    NSDictionary *apnContent = [notificationDictionary objectForKey:kUserInfoMessage];
    NSDictionary *apnExtra = [apnContent objectForKey:kUserInfoExtraMessage];
    
    NSString *joinableType = [apnExtra valueForKey:@"joinable_type"];
    NSNumber *joinableId = [apnExtra numberForKey:@"joinable_id"];
    NSNumber *userId = [apnExtra numberForKey:@"user_id"];

    NSNumber *tourId;
    if ([@"Tour" isEqualToString:joinableType]) {
        tourId = joinableId;
    }

    // Reject join
    void(^rejectBlock)(UIAlertAction * _Nonnull action) = ^void(UIAlertAction * _Nonnull action) {
        if ([@"Tour" isEqualToString:joinableType]) {
            [[OTTourService new] rejectTourJoinRequestForUser:userId
                                                      forTour:joinableId
                                                  withSuccess:^() {
                                                      NSLog(@"Rejected user's join request.");
                                                  } failure:^(NSError *error) {
                                                      NSLog(@"Something went wrong on user rejection: %@", error.description);
                                                  }];
        }
        else if ([@"Entourage" isEqualToString:joinableType]) {
            [[OTEntourageService new] rejectEntourageJoinRequestForUser:userId
                                                           forEntourage:joinableId
                                                            withSuccess:^{
                                                                NSLog(@"Rejected user's join request to entourage.");
                                                            } failure:^(NSError *error) {
                                                                NSLog(@"Something went wrong on user rejection: %@", error.description);
                                                            }];
        }
    };
    
    UIAlertAction *refuseJoinRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"refuseAlert")
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:rejectBlock
                                              ];
    
    // Accept join
    void(^acceptBlock)(UIAlertAction * _Nonnull action) = ^void(UIAlertAction * _Nonnull action) {
        if ([@"Tour" isEqualToString:joinableType]) {
            [[OTTourService new] updateTourJoinRequestStatus:@"accepted"
                                                     forUser:userId
                                                     forTour:joinableId
                                                 withSuccess:^{
                                                     NSLog(@"Accepted user's join request.");                                                                                                                 }
                                                     failure:^(NSError * error) {
                                                         NSLog(@"Something went wrong on user acceptance: %@", error.description);
                                                     }];
        }
        else if ([@"Entourage" isEqualToString:joinableType]) {
            [[OTEntourageService new] updateEntourageJoinRequestStatus:@"accepted"
                                                               forUser:userId
                                                          forEntourage:joinableId
                                                           withSuccess:^{
                                                               NSLog(@"Accepted user's entourage join request.");
                                                           } failure:^(NSError *error) {
                                                               NSLog(@"Something went wrong on user acceptance: %@", error.description);
                                                           }];
        }

    };
    UIAlertAction *acceptJoinRequestAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"acceptAlert")
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:acceptBlock
                                              ];
    [alert addAction:refuseJoinRequestAction];
    [alert addAction:acceptJoinRequestAction];
}

- (void)handleChatNotification:(NSDictionary *)notificationDictionary
                         showingAlert:(UIAlertController*)alert
{
    NSDictionary *apnContent = [notificationDictionary objectForKey:kUserInfoMessage];
    NSDictionary *apnExtra = [apnContent objectForKey:kUserInfoExtraMessage];
    
    NSNumber *joinableId = [apnExtra numberForKey:@"joinable_id"];
    NSString *type = [apnExtra valueForKey:@"joinable_type"];

    if ([@"Tour" isEqualToString:type]) {
        UIAlertAction *openTourAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"showAlert")//@"Afficher"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [[OTTourService new] getTourWithId:joinableId
                                                                                      withSuccess:^(OTTour *tour) {
                                                                                          NSLog(@"got tour info");
                                                                                          //open timeline
                                                                                          UIApplication *app = [UIApplication sharedApplication];
                                                                                          UIViewController *rootVC = app.windows.firstObject.rootViewController;
                                                                                          [rootVC dismissViewControllerAnimated:YES completion:nil];
                                                                                          UINavigationController *navC = [[UIStoryboard tourStoryboard] instantiateInitialViewController];
                                                                                          OTFeedItemViewController *tourVC = navC.viewControllers.firstObject;
                                                                                          tourVC.feedItem = (OTFeedItem*)tour;
                                                                                          [rootVC presentViewController:navC animated:YES completion:^{
                                                                                              NSLog(@"showing tour vc");
                                                                                          }];
                                                                                          
                                                                                      } failure:^(NSError *error) {
                                                                                          NSLog(@"something went wrong on getting tour info for tourId %@", joinableId);
                                                                                      }];
                                                           }];
        [alert addAction:openTourAction];
    } else {
        UIAlertAction *openEntourageAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"showAlert")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   [[OTEntourageService new] getEntourageWithId:joinableId
                                                                                          withSuccess:^(OTEntourage *entourage) {
                                                                                              NSLog(@"got entourage info");
                                                                                              //open timeline
                                                                                              UIApplication *app = [UIApplication sharedApplication];
                                                                                              UIViewController *rootVC = app.windows.firstObject.rootViewController;
                                                                                              [rootVC dismissViewControllerAnimated:YES completion:nil];
                                                                                              UINavigationController *navC = [[UIStoryboard tourStoryboard] instantiateInitialViewController];
                                                                                              OTFeedItemViewController *feedVC = navC.viewControllers.firstObject;
                                                                                              feedVC.feedItem = (OTFeedItem*)entourage;
                                                                                              [rootVC presentViewController:navC animated:YES completion:^{
                                                                                                  NSLog(@"showing entourage vc");
                                                                                              }];
                                                                                              
                                                                                          } failure:^(NSError *error) {
                                                                                              NSLog(@"something went wrong on getting entourage info for entourageId %@", joinableId);
                                                                                          }];
                                                               }];
        [alert addAction:openEntourageAction];
        
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // Retrieving the data
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"Local notification received: %@", userInfo);
    // Building the notification
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive || state == UIApplicationStateBackground ||  state == UIApplicationStateInactive) {
        
        UIApplication *app = [UIApplication sharedApplication];
        UIViewController *rootVC = app.windows.firstObject.rootViewController;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[userInfo objectForKey:kUserInfoSender]
                                                                       message:[userInfo objectForKey:kUserInfoObject]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {}];
        
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"showAlert")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                                    [rootVC dismissViewControllerAnimated:YES completion:nil];
                                                                   if ([rootVC isKindOfClass:[SWRevealViewController class]]) {
                                                                       [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationLocalTourConfirmation object:nil];
                                                                   } else {
                                                                       [UIStoryboard showSWRevealController];
                                                                   }
                                                }];
        [alert addAction:defaultAction];
        [alert addAction:openAction];
        
        if (rootVC.presentedViewController) {
            if (![((UINavigationController*)rootVC.presentedViewController).viewControllers.firstObject isKindOfClass:[OTCreateMeetingViewController class]])
                [rootVC.presentedViewController presentViewController:alert animated:YES completion:nil];
        } else
            [rootVC presentViewController:alert animated:YES completion:nil];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

/**************************************************************************************************/
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
    
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
//    [[SVProgressHUD appearance] setForegroundColor:[UIColor appOrangeColor]];
//    [[SVProgressHUD appearance] setBackgroundColor:[UIColor whiteColor]];
}

@end