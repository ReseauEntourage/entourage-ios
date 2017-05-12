//
//  OTGeolocationRightsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 13/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGeolocationRightsViewController.h"
#import "OTConsts.h"
#import "UIView+entourage.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "UINavigationController+entourage.h"
#import "UIBarButtonItem+factory.h"

@implementation OTGeolocationRightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    [self addIgnoreButton];
    [self.navigationController presentTransparentNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAuthorizationChanged:) name: kNotificationLocationAuthorizationChanged object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doIgnore").capitalizedString
                                                          withTarget:self
                                                           andAction:@selector(ignore)
                                                             colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

#pragma mark - Private

- (void)promptUserForLocationUsage {
    if ([OTLocationManager sharedInstance].isAuthorized)
        [self goToNotifications];
    else
        [[OTLocationManager sharedInstance] startLocationUpdates];
}

#pragma mark - App authorization notifications

- (void)locationAuthorizationChanged:(NSNotification *)notification {
    BOOL allowed = [notification readAllowedLocation];
    if (allowed)
        [self goToNotifications];
    else
        [self performSegueWithIdentifier:@"NoLocationRightsSegue" sender:self];
}

#pragma mark - IBAction

- (void)goToNotifications {
    [self performSegueWithIdentifier:@"GeoToNotificationsSegue" sender:self];
}

- (void)ignore {
    [[OTLocationManager sharedInstance] startLocationUpdates];
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"AcceptGeoloc"];
    [self promptUserForLocationUsage];
}

@end
