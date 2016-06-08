//
//  OTRightsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 10/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTRightsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "OTConsts.h"

// Util
#import "UIStoryboard+entourage.h"


@interface OTRightsViewController () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
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

- (void)promptUserForLocationUsage {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - CLLocationMangerDelegate

static BOOL shouldShowInfo = YES;
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    
    if (status == kCLAuthorizationStatusDenied) {
        shouldShowInfo = YES;
        [self setElementsHidden:NO];
        
    } else {
        [self promptUserForPushNotifications];
    }
}

@end
