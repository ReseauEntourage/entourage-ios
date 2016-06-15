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

    // register for push notifications
    //[self promptUserForPushNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMainStorybord)
                                                 name:kNotificationPushStatusChanged
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

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

@end
