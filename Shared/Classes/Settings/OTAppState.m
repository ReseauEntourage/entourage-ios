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
#import "OTActiveFeedItemViewController.h"
#import "OTMapViewController.h"
#import "OTAuthenticationModalViewController.h"

#define TUTORIAL_DELAY 2

#define MAP_TAB_INDEX 0
#if !PFP
    #define SOLIDARITY_MAP_INDEX 1
    #define MESSAGES_TAB_INDEX 2
#else
    #define SOLIDARITY_MAP_INDEX 0
    #define MESSAGES_TAB_INDEX 1
#endif

@implementation OTAppState

+ (void)launchApplicatioWithOptions:(NSDictionary *)launchOptions
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser) {
        
        if ([OTAppConfiguration shouldShowIntroTutorial:currentUser] &&
            ![NSUserDefaults standardUserDefaults].isTutorialCompleted) {
            [OTAppState continueFromLoginScreen:nil];

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
                    [OTAppState navigateToPermissionsScreens:nil];
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

+ (void)navigateToLoginScreen:(NSURL*)link sender:(UIViewController * _Nullable)sender
{
    OTLoginViewController *loginController = [[UIStoryboard introStoryboard] instantiateViewControllerWithIdentifier:@"OTLoginViewController"];
    loginController.fromLink = link;
    if ([sender isKindOfClass:[OTPhoneViewController class]]) {
        [sender.navigationController pushViewController:loginController animated:YES];
    }
    else {
        [[OTAppState getTopViewController] showViewController:loginController sender:self];
    }
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
    
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        UIStoryboard *introStoryboard = [UIStoryboard storyboardWithName:@"PfpIntro" bundle:nil];
        PfpStartupViewController *startupVC = [introStoryboard instantiateViewControllerWithIdentifier:@"PfpStartupViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:startupVC];
        appDelegate.window.rootViewController = navController;
        [appDelegate.window makeKeyAndVisible];
    } else {
        [UIStoryboard showInitialViewControllerFromStoryboardNamed:@"Intro" addingNavigation:NO];
    }
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
    UIViewController *firstAuthenticationScreen = [self firstAuthenticationScreenCreatingUser:createUser];
    [currentViewController.navigationController pushViewController:firstAuthenticationScreen
                                                  animated:YES];
}

+ (UIViewController *)firstAuthenticationScreenCreatingUser:(BOOL)createUser {
    BOOL pfp = [OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge;

    if (createUser || pfp) {
        OTWelcomeViewController *welcomeViewController = [[UIStoryboard introStoryboard] instantiateViewControllerWithIdentifier:@"OTWelcomeViewController"];
        welcomeViewController.signupNewUser = createUser;
        return welcomeViewController;
    }
    else {
        OTLoginViewController *loginController = [[UIStoryboard introStoryboard] instantiateViewControllerWithIdentifier:@"OTLoginViewController"];
        return loginController;
    }
}

+ (void)continueFromWelcomeScreen:(OTWelcomeViewController * _Nonnull)welcomeScreen
{
    if (welcomeScreen.signupNewUser) {
        [OTLogger logEvent:@"WelcomeScreenContinue"];
        OTPhoneViewController *onboardingViewController = [[UIStoryboard onboardingStoryboard] instantiateViewControllerWithIdentifier:@"OTPhoneViewController"];
        [welcomeScreen.navigationController pushViewController:onboardingViewController animated:YES];
    } else {
        OTLoginViewController *loginController = [[UIStoryboard introStoryboard] instantiateViewControllerWithIdentifier:@"OTLoginViewController"];
        [OTLogger logEvent:@"SplashLogIn"];
        [welcomeScreen.navigationController pushViewController:loginController animated:YES];
    }
}

+ (void)continueFromLoginScreen:(UIViewController * _Nullable)currentViewController
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser.lastName.length > 0 && currentUser.firstName.length > 0) {
        [OTAppState continueFromUserEmailScreen:currentViewController];
    }
    else {
        if (currentViewController == nil)
            currentViewController = [OTAppState getTopViewController];
        [OTAppState navigateToUserName:currentViewController];
    }
}

+ (void)continueFromUserEmailScreen:(UIViewController * _Nonnull)currentViewController
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    BOOL isFirstLogin = [[NSUserDefaults standardUserDefaults] isFirstLogin];
    
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
                [OTAppState navigateToPermissionsScreens:currentViewController];
            }
        } else {
            [OTAppState navigateToPermissionsScreens:currentViewController];
        }
    }
}

+ (void)navigateToPermissionsScreens:(UIViewController * _Nullable)currentViewController {
    if (currentViewController == nil)
        currentViewController = [OTAppState getTopViewController];
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    
    if ([currentUser hasActionZoneDefined] &&
        [currentUser isRegisteredForPushNotifications]) {
        
        [[NSUserDefaults standardUserDefaults] setTutorialCompleted];
        [[OTLocationManager sharedInstance] startLocationUpdates];
        
        [OTAppState navigateToAuthenticatedLandingScreen];
        
        if ([OTAppConfiguration shouldShowIntroTutorial:currentUser] &&
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

+ (void)continueFromUserNameScreen:(UIViewController *)currentViewController
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser.email.length > 0) {
        [OTAppState continueFromUserEmailScreen:currentViewController];
    }
    else {
        [OTAppState navigateToUserEmail:currentViewController];
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

        if ([NSUserDefaults standardUserDefaults].currentUser.isAnonymous) {
            [self presentAuthenticationOverlay:controller];
            return;
        }

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

+ (void)navigateToUserEmail:(UIViewController*)viewController {
    UIStoryboard *profileDetailsStoryboard = [UIStoryboard storyboardWithName:@"UserProfileDetails" bundle:nil];
    UIViewController *emailViewController = [profileDetailsStoryboard instantiateViewControllerWithIdentifier:@"EmailScene"];
    [viewController.navigationController pushViewController:emailViewController animated:YES];
}

+ (void)navigateToUserName:(UIViewController*)viewController {
    UIStoryboard *profileDetailsStoryboard = [UIStoryboard storyboardWithName:@"UserProfileDetails" bundle:nil];
    UIViewController *nameController = [profileDetailsStoryboard instantiateViewControllerWithIdentifier:@"NameScene"];
    if ([viewController isKindOfClass:[nameController class]]) {
        [OTAppState navigateToRootController:viewController];
        return;
    }
    [viewController.navigationController pushViewController:nameController animated:YES];
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
        if ([viewController isKindOfClass:[OTStartupViewController class]]) {
            [viewController.navigationController setViewControllers:@[rightsViewController] animated:YES];
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
        if ([viewController isKindOfClass:[OTStartupViewController class]]) {
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
    OTAuthenticationModalViewController *modalController = [OTAuthenticationModalViewController new];
    UINavigationController *authenticationFlow = [[UINavigationController alloc] initWithRootViewController:modalController];
    [OTAppConfiguration configureNavigationControllerAppearance:authenticationFlow];
    authenticationFlow.modalPresentationStyle = UIModalPresentationOverFullScreen;
    authenticationFlow.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [currentViewController presentViewController:authenticationFlow animated:YES completion:nil];
}
@end
