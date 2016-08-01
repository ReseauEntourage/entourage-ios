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

@interface OTNotificationsRightsViewController()

@property (nonatomic, weak) IBOutlet UIButton *activateButton;

@end

@implementation OTNotificationsRightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    [self addIgnoreButton];
    
    [self.activateButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushNotificationAuthorizationChanged:)
                                                 name:kNotificationPushStatusChanged
                                               object:nil];

}

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doIgnore") withTarget:self andAction:@selector(doShowNewsFeeds) colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

#pragma mark - Private

- (void)promptUserForPushNotifications {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)pushNotificationAuthorizationChanged:(NSNotification *)notification {
    NSLog(@"received kNotificationPushStatusChanged");
    [self doShowNewsFeeds];
}

#pragma mark - IBAction

- (void)doShowNewsFeeds {
    NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
    if (loggedNumbers == nil)
        loggedNumbers = [NSMutableArray new];
    [loggedNumbers addObject:[NSUserDefaults standardUserDefaults].currentUser.phone];
    [[NSUserDefaults standardUserDefaults] setObject:loggedNumbers forKey:kTutorialDone];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UIStoryboard showSWRevealController];
}

- (IBAction)doContinue {
    [self promptUserForPushNotifications];
}

@end
