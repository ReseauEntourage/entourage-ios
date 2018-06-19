//
//  OTAppState.h
//  entourage
//
//  Created by Smart Care on 23/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InviteSourceDelegate;

@interface OTAppState : NSObject
+ (void)launchApplicatioWithOptions:(NSDictionary *)launchOptions;
+ (void)returnToLogin;
+ (void)presentTutorialScreen;
+ (void)navigateToAuthenticatedLandingScreen;
+ (void)navigateToUserProfile;
+ (void)switchMapToSolidarityGuide;
+ (void)switchToMessagesScreen;

+ (void)navigateToLoginScreen:(NSURL*)link;
+ (void)navigateToStartupScreen;
+ (void)continueFromStartupScreen;
+ (void)continueFromWelcomeScreen;
+ (void)continueFromLoginScreen;
+ (void)continueFromUserEmailScreen;
+ (void)continueFromUserNameScreen;
+ (void)continueEditingEntourage:(OTEntourage*)entourage fromController:(UIViewController*)controller;
+ (void)launchInviteActionForFeedItem:(OTFeedItem*)item
                       fromController:(UIViewController*)controller
                             delegate:(id<InviteSourceDelegate>)delegate;

+ (void)hideTabBar:(BOOL)hide;
+ (void)updateMessagesTabBadgeWithValue:(NSString*)value;

+ (void)navigateToUserEmail:(UIViewController*)viewController;
+ (void)navigateToUserName:(UIViewController*)viewController;
+ (void)navigateToUserPicture:(UIViewController*)viewController;
+ (void)navigateToRightsScreen:(UIViewController*)viewController;
@end
