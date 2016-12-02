//
//  OTLocationManager.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTLocationManager.h"
#import "OTDeepLinkService.h"
#import "OTConsts.h"

@interface OTLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLAuthorizationStatus status;

@end

@implementation OTLocationManager

+ (OTLocationManager *)sharedInstance {
    static OTLocationManager* sharedInstance;
    static dispatch_once_t entourageFilterToken;
    dispatch_once(&entourageFilterToken, ^{
        sharedInstance = [self new];
        sharedInstance.isAuthorized = NO;
    });
    return sharedInstance;
}

- (void)startLocationUpdates {
    if(self.status == kCLAuthorizationStatusDenied) {
        [self notifyStatus];
        return;
    }
    
    if (self.locationManager == nil)
        self.locationManager = [[CLLocationManager alloc] init];
    //iOS 8+
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [self.locationManager requestAlwaysAuthorization];
    //iOS 9+
    if ([self.locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)])
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = 10; // meters

    [self.locationManager startUpdatingLocation];
}

- (void)stopLocationUpdates {
    [self.locationManager stopUpdatingLocation];
}

- (void)showGeoLocationNotAllowedMessage:(NSString *)message {
    [Flurry logEvent:@"ActivateGeolocFromCreateTourPopup"];
    UIViewController *rootController = [[OTDeepLinkService new] getTopViewController];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"refuseAlert") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:defaultAction];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"activate") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alert addAction:settingsAction];
    [rootController presentViewController:alert animated:YES completion:nil];
}

- (void)showLocationNotFoundMessage:(NSString *)message {
    UIViewController *rootController = [[OTDeepLinkService new] getTopViewController];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"tryAgain") message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"ok") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:defaultAction];
    [rootController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        CLLocation *item = (CLLocation *)evaluatedObject;
        return item.horizontalAccuracy >= 0 && (item.coordinate.latitude != 0 || item.coordinate.longitude != 0);
    }];
    locations = [locations filteredArrayUsingPredicate:filter];
    if([locations count] > 0)
        self.currentLocation = [locations objectAtIndex:0];
    NSDictionary *info = @{ kNotificationLocationUpdatedInfoKey: locations };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationUpdated object:nil userInfo:info];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    self.status = status;
    if(status == kCLAuthorizationStatusNotDetermined)
        return;
    [self notifyStatus];
}

- (void)notifyStatus {
    self.isAuthorized = self.status == kCLAuthorizationStatusAuthorizedAlways;
    NSDictionary *info = @{ kNotificationLocationAuthorizationChangedKey: [NSNumber numberWithBool:self.isAuthorized] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationAuthorizationChanged object:nil userInfo:info];
}

@end
