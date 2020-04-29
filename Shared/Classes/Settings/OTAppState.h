//
//  OTAppState.h
//  entourage
//
//  Created by Smart Care on 23/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTWelcomeViewController.h"

@protocol InviteSourceDelegate;
@protocol OTFeedItemsFilterDelegate;
@protocol OTSolidarityGuideFilterDelegate;
@protocol EntourageEditorDelegate;

@interface OTAppState : NSObject
+ (void)launchApplicatioWithOptions:(NSDictionary *)launchOptions;
+ (void)returnToLogin;
+ (void)presentTutorialScreen;
+ (void)loadTutorialScreen;
+ (void)navigateToAuthenticatedLandingScreen;
+ (void)navigateToUserProfile;
+ (void)switchMapToSolidarityGuide;
+ (void)switchToMessagesScreen;
+ (void)switchToMainScreenAndResetAppWindow:(BOOL)reset;
+ (UIViewController *)getTopViewController;
+ (void)popToRootCurrentTab;

+ (void)navigateToLoginScreen:(NSURL*)link sender:(UIViewController * _Nullable)sender;
+ (void)navigateToStartupScreen;
+ (void)navigateToPermissionsScreens:(UIViewController * _Nullable)currentViewController;
+ (void)continueFromStartupScreen:(UIViewController * _Nonnull)currentViewController creatingUser:(BOOL)createUser;
+ (void)continueFromWelcomeScreen:(OTWelcomeViewController * _Nonnull)welcomeScreen;
+ (void)continueFromLoginScreen:(UIViewController * _Nullable)currentViewController;
+ (void)continueFromUserEmailScreen:(UIViewController * _Nonnull)currentViewController;
+ (void)continueFromUserNameScreen:(UIViewController * _Nonnull)currentViewController;
+ (void)continueEditingEntourage:(OTEntourage*)entourage fromController:(UIViewController*)controller;

+ (void)launchFeedsFilteringFromController:(UIViewController*)controller
                             withDelegate:(id<OTFeedItemsFilterDelegate>)delegate;

+ (void)launchMapPOIsFilteringFromController:(UIViewController*)controller withDelegate:(id<OTSolidarityGuideFilterDelegate>)delegate;

+ (void)showFilteringOptionsFromController:(UIViewController*)controller
                        withFullMapVisible:(BOOL)isFullMapVisible;
    
+ (void)showFeedAndMapActionsFromController:(UIViewController*)controller
                                showOptions:(BOOL)showOptions
                               withDelegate:(id<EntourageEditorDelegate>)delegate
                             isEditingEvent:(BOOL)isEditingEvent;

+ (void)showClosingConfirmationForFeedItem:(OTFeedItem*)feedItem
                            fromController:(UIViewController*)controller
                                    sender:(id)sender;

+ (void)launchInviteActionForFeedItem:(OTFeedItem*)item
                       fromController:(UIViewController*)controller
                             delegate:(id<InviteSourceDelegate>)delegate;

+ (void)hideTabBar:(BOOL)hide;
+ (void)updateMessagesTabBadgeWithValue:(NSString*)value;

+ (void)navigateToUserEmail:(UIViewController*)viewController;
+ (void)navigateToUserName:(UIViewController*)viewController;
+ (void)navigateToUserPicture:(UIViewController*)viewController;
+ (void)navigateToLocationRightsScreen:(UIViewController*)viewController;
+ (void)navigateToNotificationsRightsScreen:(UIViewController*)viewController;
+ (void)navigateToNativeNotificationsPreferences;

+ (void)presentAuthenticationOverlay:(UIViewController * _Nonnull)currentViewController;
+(void) checkNotifcationsAndGoMainScreen;
+(void)continueFromLoginVC;
@end
