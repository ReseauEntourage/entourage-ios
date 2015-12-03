//
//  OTAppDelegate.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"

// Util
#import "UIFont+entourage.h"
#import "OTConsts.h"
#import "IQKeyboardManager.h"

const CGFloat OTNavigationBarDefaultFontSize = 18.f;

@interface OTAppDelegate () <UIApplicationDelegate>

@end

@implementation OTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[Flurry setCrashReportingEnabled:YES];
	[Flurry startSession:NSLocalizedString(@"FLURRY_API_KEY", @"")];
    [IQKeyboardManager sharedManager].enable = YES;

    [self configureUIAppearance];
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

/**************************************************************************************************/
#pragma mark - Configure UIAppearance

- (void)configureUIAppearance {
	// UIStatusBar
	UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;

	// UINavigationBar
	UIImage *navigationBarImage = [UIImage imageNamed:@"bg-top-header.png"];
	UINavigationBar.appearance.barTintColor = [UIColor clearColor];
	[[UINavigationBar appearance] setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
	[UINavigationBar.appearance setBarStyle:UIBarStyleBlackTranslucent];

	UIFont *navigationBarFont = [UIFont calibriFontWithSize:OTNavigationBarDefaultFontSize];
	UINavigationBar.appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
	[UIBarButtonItem.appearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor],
	                                                      NSFontAttributeName                                                         : navigationBarFont } forState:UIControlStateNormal];
}

@end
