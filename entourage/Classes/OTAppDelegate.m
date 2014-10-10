//
//  OTAppDelegate.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"

#import <CoreLocation/CoreLocation.h>

// Util
#import "UIFont+entourage.h"

@interface OTAppDelegate ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation OTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.locationManager = [CLLocationManager new];
    //[self.locationManager requestWhenInUseAuthorization];

    [self configureUIAppearance];
    return YES;
}

/**************************************************************************************************/
#pragma mark - Configure UIAppearance

- (void)configureUIAppearance
{
    // UIStatusBar
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    
    // UINavigationBar
    UIImage *navigationBarImage = [UIImage imageNamed:@"bg-top-header.png"];
    UINavigationBar.appearance.barTintColor = [UIColor clearColor];
    UINavigationBar.appearance.backIndicatorImage = navigationBarImage;
    UINavigationBar.appearance.backIndicatorTransitionMaskImage = navigationBarImage;
    [UINavigationBar.appearance setBarStyle:UIBarStyleBlackTranslucent];
    
    UIFont *navigationBarFont = [UIFont calibriFontWithSize:18.];
    UINavigationBar.appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [UIBarButtonItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                         NSFontAttributeName:navigationBarFont} forState:UIControlStateNormal];
}

@end
