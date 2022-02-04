//
//  OTNotificationsRightsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 13/07/16.
//  Copyright © 2016 Entourage. All rights reserved.
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
#import "OTAppState.h"
#import "OTAppConfiguration.h"
#import "NSUserDefaults+OT.h"
#import "OTAppAppearance.h"
#import "UINavigationController+entourage.h"
#import "entourage-Swift.h"

@import Firebase;

@implementation OTNotificationsRightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
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
    [self.navigationController presentTransparentNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
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
        [FIRAnalytics setUserPropertyString:notificationEnabled forName:@"EntourageNotifEnable"];
    }];
    
    if ([OTAppConfiguration shouldShowIntroTutorial:currentUser]) {
        [self setTutorialCompleted];
    }
    [self checkInvitationsToJoin];
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"AcceptNotifications"];
    [OTPushNotificationsService promptUserForAuthorizationsWithCompletionHandler:^{
        [self doShowNext];
    }];
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
