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
#import "OTStartupViewController.h"
#import "OTLoginViewController.h"
#import "OTWelcomeViewController.h"
#import "OTPhoneViewController.h"
#import "OTAPIConsts.h"
#import "OTMailSenderBehavior.h"
#import "OTInviteSourceViewController.h"
#import <UIKit/UIActivity.h>
#import "OTActivityProvider.h"
#import "OTFeedItemFiltersViewController.h"
#import "OTSolidarityGuideFiltersViewController.h"
#import "OTEntourageEditorViewController.h"
#import "OTGeolocationRightsViewController.h"
#import "OTPushNotificationsService.h"
#import "OTNotificationsRightsViewController.h"
#import "OTFeedItemFactory.h"

#define TUTORIAL_DELAY 15
#define MAP_TAB_INDEX 0
#define MESSAGES_TAB_INDEX 1

@implementation OTAppState

+ (void)launchApplicatioWithOptions:(NSDictionary *)launchOptions
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser) {
        
        if ([OTAppConfiguration shouldShowIntroTutorial] &&
            ![NSUserDefaults standardUserDefaults].isTutorialCompleted) {
            [OTAppState continueFromLoginScreen];

        } else {
            NSDictionary *pnData = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (pnData) {
                [[OTLocationManager sharedInstance] startLocationUpdates];
                [OTAppConfiguration handleAppLaunchFromNotificationCenter:pnData];
            } else {
                
                if (![currentUser hasActionZoneDefined]) {
                    // Force the users to define action zone
                    // The Entourage app has Ignore button, while the pfp does not have it
                    [OTAppState navigateToLocationRightsScreen:nil];
                } else {
                    [[OTLocationManager sharedInstance] startLocationUpdates];
                    [OTAppState navigateToPermissionsScreens];
                }
            }
        }
    }
    else
    {
        // Show intro screens
        [OTAppState navigateToStartupScreen];
    }
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

+ (void)navigateToLoginScreen:(NSURL*)link
{
    OTLoginViewController *loginController = [[UIStoryboard introStoryboard] instantiateViewControllerWithIdentifier:@"OTLoginViewController"];
    loginController.fromLink = link;
    [OTAppState returnToLogin];
    [[OTAppState getTopViewController] showViewController:loginController sender:self];
}

+ (void)returnToLogin {
    OTPushNotificationsService *pnService = [OTAppConfiguration sharedInstance].pushNotificationService;
    [SVProgressHUD show];
    
    [pnService clearTokenWithSuccess:^() {
        [SVProgressHUD dismiss];
        [OTAppConfiguration clearUserData];
        [OTAppState navigateToStartupScreen];
        
    } orFailure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [OTAppConfiguration clearUserData];
        [OTAppState navigateToStartupScreen];
    }];
}

+ (void)navigateToAuthenticatedLandingScreen
{
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    
    UITabBarController *tabBarController = [OTAppConfiguration configureMainTabBar];
    [OTAppConfiguration configureTabBarAppearance:tabBarController];
    
    window.rootViewController = tabBarController;
    [window makeKeyAndVisible];
}

+ (void)navigateToUserProfile
{
    [UIStoryboard showUserProfileDetails];
}

+ (void)navigateToStartupScreen
{
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [UIStoryboard showStartup];
}

+ (void)switchMapToSolidarityGuide {
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    tabBarController.selectedIndex = MAP_TAB_INDEX;
}

+ (void)switchToMessagesScreen {
    OTAppDelegate *appDelegate = (OTAppDelegate*)[UIApplication sharedApplication].delegate;
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    tabBarController.selectedIndex = MESSAGES_TAB_INDEX;
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
    UITabBarController *tabBarController = (UITabBarController*)appDelegate.window.rootViewController;
    [tabBarController.tabBar setHidden:hide];
}

+ (void)continueFromStartupScreen
{
    OTLoginViewController *loginController = [[UIStoryboard introStoryboard] instantiateViewControllerWithIdentifier:@"OTLoginViewController"];
    OTWelcomeViewController *welcomeViewController = [[UIStoryboard introStoryboard] instantiateViewControllerWithIdentifier:@"OTWelcomeViewController"];
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        [[OTAppState getTopViewController].navigationController pushViewController:welcomeViewController animated:YES];
    } else {
        [OTLogger logEvent:@"SplashLogIn"];
        [[OTAppState getTopViewController].navigationController pushViewController:loginController animated:YES];
    }
}

+ (void)continueFromWelcomeScreen
{
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        OTLoginViewController *loginController = [[UIStoryboard introStoryboard] instantiateViewControllerWithIdentifier:@"OTLoginViewController"];
        [OTLogger logEvent:@"SplashLogIn"];
        [[OTAppState getTopViewController].navigationController pushViewController:loginController animated:YES];
    } else {
        [OTLogger logEvent:@"WelcomeScreenContinue"];
        OTPhoneViewController *onboardingViewController = [[UIStoryboard onboardingStoryboard] instantiateViewControllerWithIdentifier:@"OTPhoneViewController"];
        [[OTAppState getTopViewController].navigationController pushViewController:onboardingViewController animated:YES];
    }
}

+ (void)continueFromLoginScreen
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser.lastName.length > 0 && currentUser.firstName.length > 0) {
        [OTAppState continueFromUserEmailScreen];
    }
    else {
        [OTAppState navigateToUserName:[OTAppState getTopViewController]];
    }
}

+ (void)continueFromUserEmailScreen
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    BOOL isFirstLogin = [[NSUserDefaults standardUserDefaults] isFirstLogin];
    UIViewController *currentViewController = [OTAppState getTopViewController];
    
    if (isFirstLogin) {
        if (currentUser.avatarURL.length == 0) {
            // If no picture yet, navigate to picture editor, add rights screens (action zone, notifications)
            [OTAppState navigateToUserPicture:currentViewController];
        } else {
            // Else: navigate to add rights screens (action zone, notifications)
            [OTAppState navigateToLocationRightsScreen:currentViewController];
        }
    } else {
        
        // For all next logins
        // If user is forced to set picture
        if ([OTAppConfiguration shouldAlwaysRequestUserToUploadPicture]) {
            if (currentUser.avatarURL.length == 0) {
                [OTAppState navigateToUserPicture:currentViewController];
            }
            else {
                [OTAppState navigateToPermissionsScreens];
            }
        } else {
            [OTAppState navigateToPermissionsScreens];
        }
    }
}

+ (void)navigateToPermissionsScreens {
    UIViewController *currentViewController = [OTAppState getTopViewController];
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    
    if ([currentUser hasActionZoneDefined] &&
        [currentUser isRegisteredForPushNotifications]) {
        
        [OTAppState navigateToAuthenticatedLandingScreen];
        
        if ([OTAppConfiguration shouldShowIntroTutorial] &&
            ![NSUserDefaults standardUserDefaults].isTutorialCompleted) {
            [OTAppState presentTutorialScreen];
        }
        
    } else if (![currentUser hasActionZoneDefined]) {
        // Navigate to add rights screens (action zone, notifications)
        // Force the users to define action zone
        // The Entourage app has Ignore button, while the pfp does not have it
        [OTAppState navigateToLocationRightsScreen:currentViewController];
        
    } else if (![currentUser isRegisteredForPushNotifications]) {
        // Navigate to notifications screen
        [OTAppState navigateToNotificationsRightsScreen:currentViewController];
    }
}

+ (void)continueFromUserNameScreen
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser.email.length > 0) {
        [OTAppState continueFromUserEmailScreen];
    }
    else {
        [OTAppState navigateToUserEmail:[OTAppState getTopViewController]];
    }
}

+ (void)continueEditingEntourage:(OTEntourage*)entourage fromController:(UIViewController*)controller {
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeEntourage) {
        [controller performSegueWithIdentifier:@"EntourageEditorSegue" sender:self];
    } else {
        if ([entourage isOuting]) {
            [controller performSegueWithIdentifier:@"EntourageEditorSegue" sender:self];
        } else {
            OTMailSenderBehavior *emailSender = [[OTMailSenderBehavior alloc] init];
            emailSender.owner = controller;
            NSString *subject = [NSString stringWithFormat:OTLocalizedString(@"pfp_edit_voisinage_mail_subject"), entourage.title];
            NSString *body = [NSString stringWithFormat:OTLocalizedString(@"pfp_edit_voisinage_mail_content"), entourage.desc];
            [emailSender sendMailWithSubject:subject andRecipient:CONTACT_PFP_TO body:body];
        }
    }
}

+ (void)launchInviteActionForFeedItem:(OTFeedItem*)item
                       fromController:(UIViewController*)controller
                             delegate:(id<InviteSourceDelegate>)delegate {
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeEntourage) {
        UIStoryboard *storyboard = [UIStoryboard activeFeedsStoryboard];
        OTInviteSourceViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OTInviteSourceViewController"];
        vc.delegate = delegate;
        [controller presentViewController:vc animated:YES completion:nil];

    } else if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        
        NSString *message = OTLocalizedString(@"pfp_share_message");
        NSURL *url = [NSURL URLWithString:item.shareUrl];
        OTActivityProvider *activity = [[OTActivityProvider alloc] initWithPlaceholderItem:@{@"body":message, @"url": url}];
        activity.emailBody = message;
        activity.emailSubject = @"";
        activity.url = url;
        NSArray *objectsToShare = @[activity];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
        [controller presentViewController:activityVC animated:YES completion:nil];
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

+ (void)launchMapPOIsFilteringFromController:(UIViewController*)controller withDelegate:(id<OTSolidarityGuideFilterDelegate>)delegate {
    
    [controller performSegueWithIdentifier:@"SolidarityGuideSegue" sender:nil];
    
//    UIStoryboard *filtersStoryboard = [UIStoryboard storyboardWithName:@"SolidarityGuideSegue" bundle:nil];
//    OTSolidarityGuideFiltersViewController *viewController = [filtersStoryboard instantiateViewControllerWithIdentifier:@"OTSolidarityGuideFiltersViewController"];
//    viewController.filterDelegate = delegate;
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//    navController.modalPresentationStyle = UIModalPresentationFullScreen;
//
//    [controller presentViewController:navController animated:YES completion:nil];
}

+ (void)createEntourageFromController:(UIViewController*)viewController
                         withDelegate:(id<EntourageEditorDelegate>)delegate
                              asEvent:(BOOL)isEvent {
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
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {

        [OTAppState createEntourageFromController:controller
                                     withDelegate:delegate
                                          asEvent:isEditingEvent];
        return;
    }
    
    if (showOptions) {
        [controller performSegueWithIdentifier:@"OTMapOptionsSegue" sender:controller];
    }
    else {
        [controller performSegueWithIdentifier:@"EntourageEditor" sender:controller];
    }
}

+ (void)showFilteringOptionsFromController:(UIViewController*)controller
                        withFullMapVisible:(BOOL)isFullMapVisible {
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        [OTAppState launchFeedsFilteringFromController:controller withDelegate:(id<OTFeedItemsFilterDelegate>)controller];
        return;
    }
    
    if (isFullMapVisible) {
        [OTAppState launchMapPOIsFilteringFromController:controller withDelegate:(id<OTSolidarityGuideFilterDelegate>)controller];
    }
    else {
        [OTAppState launchFeedsFilteringFromController:controller withDelegate:(id<OTFeedItemsFilterDelegate>)controller];
    }
}

+ (void)showClosingConfirmationForFeedItem:(OTFeedItem*)feedItem
                            fromController:(UIViewController*)controller
                                    sender:(id)sender {
    
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Supprimer la sortie ?"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:OTLocalizedString(@"yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [SVProgressHUD show];
            [[[OTFeedItemFactory createFor:feedItem] getStateTransition]
             closeWithOutcome:YES
             success:^(BOOL isTour) {
                 [SVProgressHUD dismiss];
                 [controller dismissViewControllerAnimated:YES completion:nil];
                 
             } orFailure:^(NSError *error) {
                 [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
             }];
        }]];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Non"                                                                    style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:noAction];
        [controller presentViewController:alert animated:YES completion:nil];
        
    } else {
        [controller performSegueWithIdentifier:@"ConfirmCloseSegue" sender:sender];
    }
}

+ (UIViewController *)getTopViewController {   
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    UITabBarController *tabController = (UITabBarController*)window.rootViewController;
    UINavigationController *navController = (UINavigationController*)[tabController selectedViewController];
    
    return navController.topViewController;
}

+ (void)navigateToUserEmail:(UIViewController*)viewController {
    UIStoryboard *profileDetailsStoryboard = [UIStoryboard storyboardWithName:@"UserProfileDetails" bundle:nil];
    UIViewController *emailViewController = [profileDetailsStoryboard instantiateViewControllerWithIdentifier:@"EmailScene"];
    [viewController.navigationController pushViewController:emailViewController animated:YES];
}

+ (void)navigateToUserName:(UIViewController*)viewController {
    UIStoryboard *profileDetailsStoryboard = [UIStoryboard storyboardWithName:@"UserProfileDetails" bundle:nil];
    UIViewController *nameController = [profileDetailsStoryboard instantiateViewControllerWithIdentifier:@"NameScene"];
    [viewController.navigationController pushViewController:nameController animated:YES];
}

+ (void)navigateToUserPicture:(UIViewController*)viewController {
    UIStoryboard *userPictureStoryboard = [UIStoryboard storyboardWithName:@"UserPicture" bundle:nil];
    UIViewController *pictureViewController = [userPictureStoryboard instantiateInitialViewController];
    
    if (viewController) {
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
        [viewController.navigationController pushViewController:rightsViewController animated:YES];
    } else {
        [OTAppState navigateToRootController:rightsViewController];
    }
}

+ (void)navigateToNotificationsRightsScreen:(UIViewController*)viewController {
    UIStoryboard *rightsStoryboard = [UIStoryboard storyboardWithName:@"Rights" bundle:nil];
    OTNotificationsRightsViewController *rightsViewController = [rightsStoryboard instantiateViewControllerWithIdentifier:@"OTNotificationsRightsViewController"];
    
    if (viewController) {
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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        NSString *urlString = [NSString stringWithFormat:@"App-Prefs:root=NOTIFICATIONS_ID&path=%@", [OTAppConfiguration iTunesAppId]];
        NSURL *url = [NSURL URLWithString:urlString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    } else {
        // ios 9.x
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
