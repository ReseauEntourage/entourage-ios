//
//  OTAppState.m
//  entourage
//
//  Created by Smart Care on 23/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTAppState.h"
#import "OTAppConfiguration.h"
#import "entourage-Swift.h"
#import "OTAppDelegate.h"
#import "UIStoryboard+entourage.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTLocationManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTAPIConsts.h"
#import "OTMailSenderBehavior.h"
#import "OTInviteSourceViewController.h"
#import <UIKit/UIActivity.h>
#import "OTActivityProvider.h"
#import "OTFeedItemFiltersViewController.h"
#import "OTEntourageEditorViewController.h"
#import "OTGeolocationRightsViewController.h"
#import "OTPushNotificationsService.h"
#import "OTNotificationsRightsViewController.h"
#import "OTFeedItemFactory.h"
#import "OTActiveFeedItemViewController.h"
#import "OTMapViewController.h"
#import "OTPicturePreviewViewController.h"

#define TUTORIAL_DELAY 2

#define MAP_TAB_INDEX 0
#define SOLIDARITY_MAP_INDEX 1
#define MESSAGES_TAB_INDEX 3

@implementation OTAppState

+ (void)launchApplicatioWithOptions:(NSDictionary *)launchOptions
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (!currentUser) {
        // Show intro screens
        [OTAppState navigateToStartupScreen];
        return;
    }
    
    if ([OTAppConfiguration shouldShowIntroTutorial:currentUser] &&
        ![NSUserDefaults standardUserDefaults].isTutorialCompleted) {
        [OTAppState continueFromLoginVC];

    } else {
        NSDictionary *pnData = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pnData) {
            [[OTLocationManager sharedInstance] startLocationUpdates];
            [OTAppConfiguration handleAppLaunchFromNotificationCenter:pnData];
        } else {
            [OTAppState checkNotifcationsAndGoMainScreen];
        }
    }
}

+(void) showPopNotification {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"pop_notification_title") message:OTLocalizedString(@"pop_notification_description") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionValidate = [UIAlertAction actionWithTitle:OTLocalizedString(@"pop_notification_bt_activate") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alertVC dismissViewControllerAnimated:NO completion:nil];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [OTPushNotificationsService promptUserForAuthorizationsWithCompletionHandler:^{
            }];
        });
    }];
    
    UIAlertAction *actioncancel = [UIAlertAction actionWithTitle:OTLocalizedString(@"pop_notification_bt_cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertVC addAction:actioncancel];
    [alertVC addAction:actionValidate];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIViewController *vc = [OTAppState getTopViewController];
        [vc presentViewController:alertVC animated:YES completion:nil];
    });
}

+ (void)presentTutorialScreen
{
    if (IS_PRO_USER) {
        return;
    }

    if ([NSUserDefaults standardUserDefaults].autoTutorialShown) {
        return;
    }

    [NSUserDefaults standardUserDefaults].autoTutorialShown = YES;
    
    [OTAppState performSelector:@selector(loadTutorialScreen) withObject:nil afterDelay:TUTORIAL_DELAY];
}

+ (void)loadTutorialScreen {
    UIStoryboard *tutorialStoryboard = [UIStoryboard storyboardWithName:@"Tutorial" bundle:nil];
    UIViewController *tutorialController = [tutorialStoryboard instantiateInitialViewController];
    [[OTAppState getTopViewController] presentViewController:tutorialController animated:YES completion:nil];
}

+ (void)navigateToLoginScreen:(NSURL*)link sender:(UIViewController * _Nullable)sender
{
    OTLoginV2ViewController *loginVC = [[UIStoryboard introStoryboard]instantiateViewControllerWithIdentifier:@"LoginV2VC"];
    loginVC.fromLink = link;
    
    [[OTAppState getTopViewController] showViewController:loginVC sender:self];
}

+ (void)returnToLogin {
    [OTAppConfiguration clearUserData];
    [OTAppState navigateToStartupScreen];
}

+ (void)navigateToAuthenticatedLandingScreen
{
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    
     UITabBarController *tabBarController = [OTAppConfiguration configureMainTabBarWithDefaultSelectedIndex:MAP_TAB_INDEX];
    
    [OTAppConfiguration configureTabBarAppearance:tabBarController];
    
    window.rootViewController = tabBarController;
    [window makeKeyAndVisible];
}


+ (void)navigateToStartupScreen
{
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [UIStoryboard showInitialViewControllerFromStoryboardNamed:@"Intro" addingNavigation:NO];
}

+ (void)switchMapToSolidarityGuide {
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    tabBarController.selectedIndex = SOLIDARITY_MAP_INDEX;
}

+ (void)switchToMessagesScreen {
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    tabBarController.selectedIndex = MESSAGES_TAB_INDEX;
}

+ (void)popToRootCurrentTab {
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    UINavigationController *navController = (UINavigationController*)tabBarController.selectedViewController;
    [navController popToRootViewControllerAnimated:NO];
}

+ (void)switchToMainScreenAndResetAppWindow:(BOOL)reset {
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    tabBarController.selectedIndex = MAP_TAB_INDEX;
    
    if (reset) {
        UIWindow *window = [appDelegate window];
        window.rootViewController = tabBarController;
        [window makeKeyAndVisible];
    }
}

+ (void)updateMessagesTabBadgeWithValue:(NSString*)value {
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    if (![appDelegate.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        return;
    }
    UITabBarItem *item = tabBarController.tabBar.items[MESSAGES_TAB_INDEX];
    
    if (@available(iOS 10.0, *)) {
        item.badgeColor = [UIColor redColor];
    }

    NSString *badgeValue = value;
    
    if (!value ||
        [value isEqualToString:@""] ||
        ([value isEqualToString:@"0"])) {
        badgeValue = nil;
    }
    
    item.badgeValue = badgeValue;
}

+ (void)hideTabBar:(BOOL)hide {
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    id root = appDelegate.window.rootViewController;
    if ([root isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController*)root;
        [tabBarController.tabBar setHidden:hide];
    } else {
        [OTAppState navigateToAuthenticatedLandingScreen];
    }
}

+ (void)continueFromStartupScreen:(UIViewController * _Nonnull)currentViewController creatingUser:(BOOL)createUser; {
    UIViewController *firstAuthenticationScreen = [[UIStoryboard introStoryboard] instantiateViewControllerWithIdentifier:@"LoginV2VC"];
    [currentViewController.navigationController pushViewController:firstAuthenticationScreen
                                                  animated:YES];
}

+(void)continueFromLoginVC {
    [OTAppState navigateToAuthenticatedLandingScreen];
    [OTAppState checkNotifcationsAndGoMainScreen];
}

+(void)checkNotifcationsAndGoMainScreen {
  [self checkNotificationsWithCompletionHandler:^{
    [[NSUserDefaults standardUserDefaults] setTutorialCompleted];
    [[OTLocationManager sharedInstance] startLocationUpdates];

    [OTAppState navigateToAuthenticatedLandingScreen];
  }];
}

+(void)checkNotificationsWithCompletionHandler:(void (^)(void))completionHandler {
    [OTPushNotificationsService getAuthorizationStatusWithCompletionHandler:^(UNAuthorizationStatus status) {
        if (@available(iOS 12.0, *)) {
            if (status == UNAuthorizationStatusProvisional)
                status = UNAuthorizationStatusNotDetermined;
        }

        dispatch_async(dispatch_get_main_queue(), ^() {
            if (status == UNAuthorizationStatusNotDetermined) {
                [OTAppState showPopNotification];
            }
            if (completionHandler != nil) {
                completionHandler();
            }
        });
    }];
}


+ (void)continueFromUserEmailScreen:(UIViewController * _Nonnull)currentViewController
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    BOOL isFirstLogin = [[NSUserDefaults standardUserDefaults] isFirstLogin];
    
    if (currentUser.avatarURL.length == 0 && (isFirstLogin || [OTAppConfiguration shouldAlwaysRequestUserToUploadPicture])) {
        [OTAppState navigateToUserPicture:currentViewController];
    } else {
        [OTAppState navigateToPermissionsScreens:currentViewController];
    }
}

+ (void)navigateToPermissionsScreens:(UIViewController * _Nullable)currentViewController {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    
    if (![currentUser hasActionZoneDefined]) {
        // Navigate to add rights screens (action zone, notifications)
        // Force the users to define action zone
        [OTAppState navigateToLocationRightsScreen:currentViewController];
        return;
    }

    [OTPushNotificationsService getAuthorizationStatusWithCompletionHandler:^(UNAuthorizationStatus status) {
        if (@available(iOS 12.0, *)) {
            if (status == UNAuthorizationStatusProvisional)
                status = UNAuthorizationStatusNotDetermined;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (status == UNAuthorizationStatusNotDetermined) {
                [OTAppState navigateToNotificationsRightsScreen:currentViewController];
            } else {
                [[NSUserDefaults standardUserDefaults] setTutorialCompleted];
                [[OTLocationManager sharedInstance] startLocationUpdates];
                
                [OTAppState navigateToAuthenticatedLandingScreen];
                
                if ([OTAppConfiguration shouldShowIntroTutorial:currentUser] &&
                    ![NSUserDefaults standardUserDefaults].isTutorialCompleted) {
                    [OTAppState presentTutorialScreen];
                }
            }
        });
    }];
}

+ (void)continueEditingEntourage:(OTEntourage*)entourage fromController:(UIViewController*)controller {
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeEntourage) {
        [controller performSegueWithIdentifier:@"EntourageEditorSegue" sender:self];
    }
}

+ (void)launchInviteActionForFeedItem:(OTFeedItem*)item
                       fromController:(UIViewController*)controller
                             delegate:(id<InviteSourceDelegate>)delegate {
    
    if ([item.status isEqualToString:ENTOURAGE_STATUS_SUSPENDED]) {
        [SVProgressHUD showErrorWithStatus:@"Invitation impossible"];
        return;
    }
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeEntourage) {
        UIStoryboard *storyboard = [UIStoryboard activeFeedsStoryboard];
        OTInviteSourceViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OTInviteSourceViewController"];
        vc.delegate = delegate;
        vc.feedItem = item;
        [controller presentViewController:vc animated:YES completion:nil];

    }
}

+ (void)launchFeedsFilteringFromController:(UIViewController*)controller withDelegate:(id<OTFeedItemsFilterDelegate>)delegate {
    
    [controller performSegueWithIdentifier:@"FiltersSegue" sender:nil];
    
//    UIStoryboard *filtersStoryboard = [UIStoryboard storyboardWithName:@"FiltersSegue" bundle:nil];
//    OTFeedItemFiltersViewController *viewController = [filtersStoryboard instantiateViewControllerWithIdentifier:@"OTFeedItemFiltersViewController"];
//    viewController.filterDelegate = delegate;
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//    navController.modalPresentationStyle = UIModalPresentationFullScreen;
//
//    [controller presentViewController:navController animated:YES completion:nil];
}

+ (void)launchMapPOIsFilteringFromController:(UIViewController*)controller withDelegate:(id<OTGuideFilterDelegate>)delegate {
    
    [controller performSegueWithIdentifier:@"SolidarityGuideFiltersSegue" sender:nil];
    
}

+ (void)createEntourageFromController:(UIViewController*)viewController
                         withDelegate:(id<EntourageEditorDelegate>)delegate
                              asEvent:(BOOL)isEvent {
    if ([NSUserDefaults standardUserDefaults].currentUser.isAnonymous) {
        [self presentAuthenticationOverlay:viewController];
        return;
    }

    UIStoryboard *editEntourageStoryboard = [UIStoryboard storyboardWithName:@"EntourageEditor" bundle:nil];
    UINavigationController *navController = (UINavigationController*)[editEntourageStoryboard instantiateInitialViewController];
    OTEntourageEditorViewController *controller = (OTEntourageEditorViewController *)navController.childViewControllers[0];
    controller.entourageEditorDelegate = delegate;
    controller.isEditingEvent = YES;
    
    [viewController presentViewController:navController animated:YES completion:nil];
}
    
+ (void)showFeedAndMapActionsFromController:(UIViewController*)controller
                                showOptions:(BOOL)showOptions
                               withDelegate:(id<EntourageEditorDelegate>)delegate
                             isEditingEvent:(BOOL)isEditingEvent {
    
    if (showOptions) {
        [controller performSegueWithIdentifier:@"OTMapOptionsSegue" sender:controller];
    }
    else {

        if ([NSUserDefaults standardUserDefaults].currentUser.isAnonymous) {
            [self presentAuthenticationOverlay:controller];
            return;
        }

        [controller performSegueWithIdentifier:@"EntourageEditor" sender:controller];
    }
}

+ (void)showFilteringOptionsFromController:(UIViewController*)controller
                        withFullMapVisible:(BOOL)isFullMapVisible {
    
    if (isFullMapVisible) {
        [OTAppState launchMapPOIsFilteringFromController:controller withDelegate:(id<OTGuideFilterDelegate>)controller];
    }
    else {
        [OTAppState launchFeedsFilteringFromController:controller withDelegate:(id<OTFeedItemsFilterDelegate>)controller];
    }
}

+ (void)showClosingConfirmationForFeedItem:(OTFeedItem*)feedItem
                            fromController:(UIViewController*)controller
                                    sender:(id)sender {
    
    [controller performSegueWithIdentifier:@"ConfirmCloseSegue" sender:sender];
}

+ (UIViewController *)getTopViewController {
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];

    if ([window.rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController*)window.rootViewController;
        UINavigationController *navController = (UINavigationController*)[tabController selectedViewController];
        return navController.topViewController;
    }
    
    if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController*)window.rootViewController;
        return navController.topViewController;
    }

    return window.rootViewController;
}

+ (void)navigateToUserPicture:(UIViewController*)viewController {
    UIStoryboard *userPictureStoryboard = [UIStoryboard storyboardWithName:@"UserPicture" bundle:nil];
    UIViewController *pictureViewController = [userPictureStoryboard instantiateInitialViewController];
    
    if (viewController) {
        if ([viewController isKindOfClass:[pictureViewController class]]) {
            [OTAppState navigateToRootController:pictureViewController];
            return;
        }
        [viewController.navigationController pushViewController:pictureViewController animated:YES];
    } else {
        [OTAppState navigateToRootController:pictureViewController];
    }
}

+ (void)navigateToLocationRightsScreen:(UIViewController*)viewController {
    UIStoryboard *rightsStoryboard = [UIStoryboard storyboardWithName:@"Rights" bundle:nil];
    OTGeolocationRightsViewController *rightsViewController = (OTGeolocationRightsViewController*)[rightsStoryboard instantiateInitialViewController];
    rightsViewController.isShownOnStartup = YES;
    
    if (viewController) {
        if ([viewController isKindOfClass:[rightsViewController class]]) {
            [OTAppState navigateToRootController:rightsViewController];
            return;
        }
        // when coming from the startup page, prevent back navigation
        if ([viewController isKindOfClass:[OTPreOnboardingV2ViewController class]]) {
            [viewController.navigationController setViewControllers:@[rightsViewController] animated:YES];
            return;
        }
        if ([viewController isKindOfClass:[OTPicturePreviewViewController class]]) {
            [viewController performSegueWithIdentifier:@"PreviewToGeoSegue" sender:viewController];
            return;
        }
        [viewController.navigationController pushViewController:rightsViewController animated:YES];
    } else {
        [OTAppState navigateToRootController:rightsViewController];
    }
}

+ (void)navigateToNotificationsRightsScreen:(UIViewController*)viewController {
    UIStoryboard *rightsStoryboard = [UIStoryboard storyboardWithName:@"Rights" bundle:nil];
    OTNotificationsRightsViewController *rightsViewController = [rightsStoryboard instantiateViewControllerWithIdentifier:@"OTNotificationsRightsViewController"];
    
    if (viewController) {
        if ([viewController isKindOfClass:[rightsViewController class]]) {
            [OTAppState navigateToRootController:rightsViewController];
            return;
        }
        // when coming from the startup page, prevent back navigation
        if ([viewController isKindOfClass:[OTPreOnboardingV2ViewController class]]) {
            [viewController.navigationController setViewControllers:@[rightsViewController] animated:YES];
            return;
        }
        [viewController.navigationController pushViewController:rightsViewController animated:YES];
    } else {
        [OTAppState navigateToRootController:rightsViewController];
    }
}

+ (void)navigateToRootController:(UIViewController*)viewController {
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    window.rootViewController = navController;
    [window makeKeyAndVisible];
}

+ (void)navigateToNativeNotificationsPreferences {
    [OTLogger logEvent:@"ToNotifications"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

+ (void)presentAuthenticationOverlay:(UIViewController * _Nonnull)currentViewController {
    // Not used anymore but called
}
@end
