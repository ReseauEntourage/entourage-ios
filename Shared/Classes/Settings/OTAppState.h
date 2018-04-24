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
+ (void)navigateToAuthenticatedLandingScreen;
+ (void)navigateToUserProfile;
+ (void)navigateToStartupScreen;
+ (void)continueFromStartupScreen;
+ (void)continueFromWelcomeScreen;
@end
