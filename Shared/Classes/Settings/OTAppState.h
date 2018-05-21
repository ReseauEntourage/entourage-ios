//
//  OTAppState.h
//  entourage
//
//  Created by Smart Care on 23/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTAppState : NSObject
+ (void)launchApplicatioWithOptions:(NSDictionary *)launchOptions;
+ (void)returnToLogin;
+ (void)presentTutorialScreen;
+ (void)navigateToAuthenticatedLandingScreen;
+ (void)navigateToUserProfile;
+ (void)switchMapToSolidarityGuide;
+ (void)navigateToLoginScreen:(NSURL*)link;
+ (void)navigateToStartupScreen;
+ (void)continueFromStartupScreen;
+ (void)continueFromWelcomeScreen;
+ (void)continueFromLoginScreen;
+ (void)continueFromUserEmailScreen;
+ (void)continueFromUserNameScreen;

+ (void)navigateToUserEmail:(UIViewController*)viewController;
+ (void)navigateToUserName:(UIViewController*)viewController;
+ (void)navigateToUserPicture:(UIViewController*)viewController;
+ (void)navigateToRightsScreen:(UIViewController*)viewController;
@end
