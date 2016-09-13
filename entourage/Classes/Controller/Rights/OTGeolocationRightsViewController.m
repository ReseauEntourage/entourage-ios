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

@interface OTGeolocationRightsViewController()

@property (nonatomic, weak) IBOutlet UIButton *activateButton;

@end

@implementation OTGeolocationRightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    [self addIgnoreButton];
    [self.navigationController presentTransparentNavigationBar];
    
    [self.activateButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationAuthorizationChanged:)
                                                 name:kNotificationLocationAuthorizationChanged
                                               object:nil];

    
}

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doIgnore").capitalizedString withTarget:self andAction:@selector(goToNotifications) colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

#pragma mark - Private

- (void)promptUserForLocationUsage {
    if ([OTLocationManager sharedInstance].started)
        [self goToNotifications];
    else
        [[OTLocationManager sharedInstance] startLocationUpdates];
}

#pragma mark - App authorization notifications

- (void)locationAuthorizationChanged:(NSNotification *)notification {
    NSLog(@"received kNotificationLocationAuthorizationChanged");
    BOOL allowed = [notification readAllowedLocation];
    if (allowed)
        [self goToNotifications];
    else
#warning What to show?
        ;
}

#pragma mark - IBAction

- (void)goToNotifications {
    [self performSegueWithIdentifier:@"GeoToNotificationsSegue" sender:self];
}

- (IBAction)doContinue {
    [self promptUserForLocationUsage];
}

@end
