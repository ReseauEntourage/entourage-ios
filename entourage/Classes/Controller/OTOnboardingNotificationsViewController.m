//
//  OTOnboardingNotificationsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 13/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingNotificationsViewController.h"
#import "OTConsts.h"
#import "UIStoryboard+entourage.h"
#import "UIView+entourage.h"
#import "NSNotification+entourage.h"

@interface OTOnboardingNotificationsViewController()

@property (nonatomic, weak) IBOutlet UIButton *activateButton;

@end


@implementation OTOnboardingNotificationsViewController

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
    UIBarButtonItem *ignoreButton = [[UIBarButtonItem alloc] initWithTitle:OTLocalizedString(@"doIgnore")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(doIgnore)];
    [ignoreButton setTintColor:[UIColor whiteColor]];
    [ignoreButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
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
    [UIStoryboard showSWRevealController];
}

#pragma mark - IBAction

- (void)doIgnore {
    [UIStoryboard showSWRevealController];
}

- (IBAction)doContinue {
    [self promptUserForPushNotifications];
}



@end
