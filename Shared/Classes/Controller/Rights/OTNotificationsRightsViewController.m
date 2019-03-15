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
#import "OTLogger.h"

@import Firebase;

@implementation OTNotificationsRightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.notificationEnabled = @"NO";
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
    self.notificationEnabled = @"YES";
    [self doShowNext];
}

#pragma mark - IBAction

- (void)doShowNext {
    [OTLogger storeGeolocEnableStatus:self.notificationEnabled];
    
    if ([OTAppConfiguration shouldShowIntroTutorial]) {
        [self setTutorialCompleted];
    }
    [self checkInvitationsToJoin];
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"AcceptNotifications"];
    [[OTPushNotificationsService new] promptUserForPushNotifications];
}

#pragma mark - private methods

- (void)setTutorialCompleted {
    NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
    if (loggedNumbers == nil)
        loggedNumbers = [NSMutableArray new];
    [loggedNumbers addObject:[NSUserDefaults standardUserDefaults].currentUser.phone];
    [[NSUserDefaults standardUserDefaults] setObject:loggedNumbers forKey:kTutorialDone];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkInvitationsToJoin {
    [SVProgressHUD show];
    [[OTOnboardingJoinService new] checkForJoins:^(OTEntourageInvitation *joinedInvitation) {
        [SVProgressHUD dismiss];
        
        if (joinedInvitation) {
            [SVProgressHUD showWithStatus:OTLocalizedString(@"joiningEntouragesMessage")];
            [[OTDeepLinkService new] navigateToFeedWithNumberId:joinedInvitation.entourageId withType:nil];
            
            if ([OTAppConfiguration shouldShowIntroTutorial] &&
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
