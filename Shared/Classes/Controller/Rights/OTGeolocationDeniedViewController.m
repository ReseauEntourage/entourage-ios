//
//  OTGeolocationDeniedViewController.m
//  entourage
//
//  Created by sergiu buceac on 10/4/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGeolocationDeniedViewController.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "entourage-Swift.h"

@implementation OTGeolocationDeniedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    [self.activateButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    [self.ignoreButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    self.titleLabel.text = [OTAppAppearance notificationsNeedDescription];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationAuthorizationChanged:)
                                                 name: kNotificationLocationAuthorizationChanged
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)activateGeolocation {
    [OTLogger logEvent:@"ActivateGeolocFromScreen04_4UserBlocked"];
    [self promptUserForLocationUsage];
    [self performSegueWithIdentifier:@"GrantedGeoSegue" sender:self];
}

- (IBAction)ignoreGeolocation {
    [self performSegueWithIdentifier:@"GrantedGeoSegue" sender:self];
}

#pragma mark - private methods

- (void)locationAuthorizationChanged:(NSNotification *)notification {
    BOOL allowed = [notification readAllowedLocation];
    if (allowed) {
        [OTLogger logEvent:@"Screen04_GoEnableGeolocView"];
        [self performSegueWithIdentifier:@"GrantedGeoSegue" sender:self];
    }
}

- (void)promptUserForLocationUsage {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
