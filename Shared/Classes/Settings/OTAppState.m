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

#define TUTORIAL_DELAY 15

@implementation OTAppState

+ (void)launchApplicatioWithOptions:(NSDictionary *)launchOptions
{
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if (currentUser) {
        
        if ([OTAppConfiguration shouldShowIntroTutorial]) {
            if ([NSUserDefaults standardUserDefaults].isTutorialCompleted) {
                [[OTLocationManager sharedInstance] startLocationUpdates];
                NSDictionary *pnData = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
                if (pnData) {
                    [OTAppConfiguration handleAppLaunchFromNotificationCenter:pnData];
                } else {
                    [OTAppState navigateToAuthenticatedLandingScreen];
                }
            }
            else {
                [OTAppState continueFromLoginScreen];
            }
        }
        else {
            [OTAppState continueFromLoginScreen];
        }
    }
    else
    {
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
    tabBarController.selectedIndex = 0;
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
    
    if ([OTAppConfiguration shouldAlwaysRequestUserToUploadPicture] || isFirstLogin) {
        if (currentUser.avatarURL.length > 0) {
            if (currentViewController) {
                [OTAppState navigateToRightsScreen:currentViewController];
            } else {
                [OTAppState navigateToAuthenticatedLandingScreen];
            }
        }
        else {
            if (currentViewController) {
                [OTAppState navigateToUserPicture:currentViewController];
            } else {
                [OTAppState navigateToAuthenticatedLandingScreen];
            }
        }
    } else {
        if (currentViewController) {
            [OTAppState navigateToRightsScreen:currentViewController];
        } else {
            [OTAppState navigateToAuthenticatedLandingScreen];
        }        
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

+ (UIViewController *)getTopViewController {
    UIViewController *result = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([result isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController*)result;
        result = navController.topViewController;
    }
    return result;
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
    [viewController.navigationController pushViewController:pictureViewController animated:YES];
}

+ (void)navigateToRightsScreen:(UIViewController*)viewController {
    UIStoryboard *rightsStoryboard = [UIStoryboard storyboardWithName:@"Rights" bundle:nil];
    UIViewController *rightsViewController = [rightsStoryboard instantiateInitialViewController];
    [viewController.navigationController pushViewController:rightsViewController animated:YES];
}

@end
