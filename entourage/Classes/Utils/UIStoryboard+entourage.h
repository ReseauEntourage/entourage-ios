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
+ (void)showUserProfileDetails;
+ (void)showSWRevealController;
+ (UIStoryboard*)tourStoryboard;
+ (UIStoryboard*)entourageCreatorStoryboard;

@end
