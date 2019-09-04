//
//  OTNotificationsRightsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 13/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTNotificationsRightsViewController.h"
#import "OTConsts.h"
#import "UIStoryboard+entourage.h"
#import "UIView+entourage.h"
#import "NSNotification+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTEntourageInvitation.h"
#import "OTOnboardingJoinService.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTDeepLinkService.h"
#import "OTPushNotificationsService.h"
#import "OTLocationManager.h"
#import <Mixpanel/Mixpanel.h>
#import "OTAppState.h"
#import "OTAppConfiguration.h"
#import "NSUserDefaults+OT.h"
#import "OTAppAppearance.h"
#import "entourage-Swift.h"

@import Firebase;

@implementation OTNotificationsRightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationAuthorizationChanged:) name:kNotificationPushStatusChanged object:nil];
    
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    
    self.descLabel.text = [OTAppAppearance notificationsRightsDescription];
    
    [self.continueButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    
    [self addIgnoreButton];
}

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doIgnore")
                                                          withTarget:self
                                                           andAction:@selector(doShowNext)
                                                             andFont:@"SFUIText-Bold"
                                                             colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[OTLocationManager sharedInstance] startLocationUpdates];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
}

#pragma mark - Private

- (void)pushNotificationAuthorizationChanged:(NSNotification *)notification {
    NSLog(@"received kNotificationPushStatusChanged");
    [self doShowNext];
}

#pragma mark - IBAction

- (void)doShowNext {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    
    [OTPushNotificationsService getAuthorizationStatusWithCompletionHandler:^(UNAuthorizationStatus status) {
        NSString *notificationEnabled = status == UNAuthorizationStatusAuthorized ? @"YES" : @"NO";
        if (@available(iOS 12.0, *)) {
            if (status == UNAuthorizationStatusProvisional)
                notificationEnabled = @"Provisional";
        }
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people set:@{@"EntourageNotifEnable": notificationEnabled}];
        [FIRAnalytics setUserPropertyString:notificationEnabled forName:@"EntourageNotifEnable"];
    }];
    
    if ([OTAppConfiguration shouldShowIntroTutorial:currentUser]) {
        [self setTutorialCompleted];
    }
    [self checkInvitationsToJoin];
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"AcceptNotifications"];
    [OTPushNotificationsService promptUserForAuthorizations];
}

#pragma mark - private methods

- (void)setTutorialCompleted {
    [[NSUserDefaults standardUserDefaults] setTutorialCompleted];
}

- (void)checkInvitationsToJoin {
    [SVProgressHUD show];
    [[OTOnboardingJoinService new] checkForJoins:^(OTEntourageInvitation *joinedInvitation) {
        [SVProgressHUD dismiss];
        
        if (joinedInvitation) {
            [SVProgressHUD showWithStatus:OTLocalizedString(@"joiningEntouragesMessage")];
            [[OTDeepLinkService new] navigateToFeedWithNumberId:joinedInvitation.entourageId withType:nil];
            
            OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
            if ([OTAppConfiguration shouldShowIntroTutorial:currentUser] &&
                ![NSUserDefaults standardUserDefaults].isTutorialCompleted) {
                [OTAppState navigateToAuthenticatedLandingScreen];
                [OTAppState presentTutorialScreen];
            }
        }
        else {
            [OTAppState navigateToAuthenticatedLandingScreen];
        }
    } withError:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"automaticJoinFailedMessage")];
        [OTAppState navigateToAuthenticatedLandingScreen];
    }];
}

@end
