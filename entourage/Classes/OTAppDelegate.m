//
//  OTAppDelegate.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "SCSoundCloud+Private.h"
#import "OTAppDelegate.h"

// Util
#import "UIFont+entourage.h"
#import "OTConsts.h"

#import <OTAppaloosa/OTAppaloosa.h>

const CGFloat OTNavigationBarDefaultFontSize = 18.f;

@interface OTAppDelegate () <UIApplicationDelegate, OTAppaloosaAgentDelegate>

@end

@implementation OTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[Flurry setCrashReportingEnabled:YES];
	[Flurry startSession:NSLocalizedString(@"FLURRY_API_KEY", @"")];

	[[OTAppaloosaAgent sharedAgent] feedbackControllerWithDefaultButtonAtPosition:kAppaloosaButtonPositionRightBottom
	                                                      forRecipientsEmailArray:@[@"entourage@octo.com"]];
	[[OTAppaloosaAgent sharedAgent] devPanelWithDefaultButtonAtPosition:kAppaloosaButtonPositionRightBottom];


	[[OTAppaloosaAgent sharedAgent] registerWithStoreId:NSLocalizedString(@"APPALOOSA_STORE_ID", @"")
	                                         storeToken:NSLocalizedString(@"APPALOOSA_STORE_TOKEN", @"")
	                                        andDelegate:self];

	[self configureSoundCloud];
	[self loginToSoundCloud];

	[self configureUIAppearance];
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
#ifndef DEBUG
	[[OTAppaloosaAgent sharedAgent] checkUpdates];
	[[OTAppaloosaAgent sharedAgent] checkAuthorizations];
#endif
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

/********************************************************************************/
#pragma mark - Configure SoundCloud

- (void)loginToSoundCloud {
	[[SCSoundCloud shared] requestAccessWithUsername:LOGIN_API_SOUNDCLOUD
	                                        password:PASS_API_SOUNDCLOUD];
}

- (void)configureSoundCloud {
    [SCSoundCloud setClientID:CLIENT_ID_API_SOUNDCLOUD
	                   secret:SECRET_API_SOUNDCLOUD
	              redirectURL:[NSURL URLWithString:@"dev-entourage-ios://oauth"]];
}

@end
