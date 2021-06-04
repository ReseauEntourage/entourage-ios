//
//  UIStoryboard+entourage.h
//  entourage
//
//  Created by Ciprian Habuc on 09/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (entourage)

+ (void)showStartup;
+ (void)showSWRevealController;
+ (void)showTabBarControllerFromStoryboardNamed:(NSString *)storyboardName;
+ (UIStoryboard*)entourageEditorStoryboard;
+ (void)showInitialViewControllerFromStoryboardNamed:(NSString *)storyboardName addingNavigation:(BOOL)addNavigation;


+ (UIStoryboard *)introStoryboard;
+ (UIStoryboard *)onboardingStoryboard;
+ (UIStoryboard *)mainStoryboard;
+ (UIStoryboard *)myEntouragesStoryboard;
+ (UIStoryboard *)aboutStoryboard;
+ (UIStoryboard *)userProfileStoryboard;
+ (UIStoryboard *)editUserProfileStoryboard;
+ (UIStoryboard *)activeFeedsStoryboard;

@end
