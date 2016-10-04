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

@implementation OTGeolocationDeniedViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAuthorizationChanged:) name: kNotificationLocationAuthorizationChanged object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private methods

- (void)locationAuthorizationChanged:(NSNotification *)notification {
    BOOL allowed = [notification readAllowedLocation];
    if(allowed)
        [self performSegueWithIdentifier:@"GrantedGeoSegue" sender:self];
}

@end
