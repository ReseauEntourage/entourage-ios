//
//  OTOnboardingGeolocationViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 13/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingGeolocationViewController.h"
#import "OTConsts.h"
#import "UIView+entourage.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "UINavigationController+entourage.h"

@interface OTOnboardingGeolocationViewController()

@property (nonatomic, weak) IBOutlet UIButton *activateButton;

@end

@implementation OTOnboardingGeolocationViewController

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
    UIBarButtonItem *ignoreButton = [[UIBarButtonItem alloc] initWithTitle:OTLocalizedString(@"doIgnore")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(doIgnore)];
    [ignoreButton setTintColor:[UIColor whiteColor]];
    [ignoreButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

#pragma mark - Private

- (void)promptUserForLocationUsage {
    if ([OTLocationManager sharedInstance].started) {
        [self performSegueWithIdentifier:@"GeoToNotificationsSegue" sender:self];
    } else {
        [[OTLocationManager sharedInstance] startLocationUpdates];
    }
}


#pragma mark - App authorization notifications

- (void)locationAuthorizationChanged:(NSNotification *)notification {
    NSLog(@"received kNotificationLocationAuthorizationChanged");
    BOOL allowed = [notification readAllowedLocation];
    if (allowed) {
        [self performSegueWithIdentifier:@"GeoToNotificationsSegue" sender:self];
    } else {
#warning What to show?
    }
}

#pragma mark - IBAction

- (void)doIgnore {
    [self performSegueWithIdentifier:@"GeoToNotificationsSegue" sender:self];
}

- (IBAction)doContinue {
    [self promptUserForLocationUsage];
//#if SKIP_ONBOARDING_REQUESTS
//    [self performSegueWithIdentifier:@"GeoToNotificationsSegue" sender:self];
//    return;
//#endif
}

@end
