    //
//  OTRightsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 10/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTRightsViewController.h"
#import "OTConsts.h"

// Util
#import "UIStoryboard+entourage.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"

@interface OTRightsViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UILabel *explanationLabel;

@end

@implementation OTRightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setElementsHidden:YES];

    // prompt the user for location usage
    [self promptUserForLocationUsage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMainStorybord)
                                                 name:kNotificationPushStatusChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAuthorizationChanged:) name:kNotificationLocationAuthorizationChanged object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)promptUserForLocationUsage {
    [[OTLocationManager sharedInstance] startLocationUpdates];
}

- (void)promptUserForPushNotifications {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)setElementsHidden:(BOOL) hidden {
    self.backgroundImageView.hidden = hidden;
    self.logoImageView.hidden = hidden;
    self.explanationLabel.hidden = hidden;
}

- (void)showMainStorybord {
    NSLog(@"received kNotificationPushStatusChanged");
    [UIStoryboard showSWRevealController];
}

#pragma mark - Location notifications

- (void)locationAuthorizationChanged:(NSNotification *)notification {
    BOOL allowed = [notification readAuthorizationAllowed];
    if(allowed)
        [self promptUserForPushNotifications];
    else
        [self setElementsHidden:NO];
}

@end
