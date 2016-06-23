//
//  OTLocationManager.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "OTLocationManager.h"

@interface OTLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation OTLocationManager

+ (OTLocationManager *)sharedInstance {
    static OTLocationManager* sharedInstance;
    static dispatch_once_t entourageFilterToken;
    dispatch_once(&entourageFilterToken, ^{
        sharedInstance = [self new];
        sharedInstance.started = NO;
    });
    return sharedInstance;
}

- (void)startLocationUpdates {
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        //iOS 8+
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        //iOS 9+
        if ([self.locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
            self.locationManager.allowsBackgroundLocationUpdates = YES;
        }
    }
    
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    self.locationManager.distanceFilter = 5; // meters
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        CLLocation *item = (CLLocation *)evaluatedObject;
        return item.horizontalAccuracy >= 0;
    }];
    NSDictionary *info = @{ kNotificationLocationUpdatedInfoKey: [locations filteredArrayUsingPredicate:filter] };
    NSLog(@"Location manager did update location: %@", info);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationUpdated object:self userInfo:info];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined)
        return;
    
    self.started = status == kCLAuthorizationStatusAuthorizedAlways;
    NSDictionary *info = @{ kNotificationLocationAuthorizationChangedKey: [NSNumber numberWithBool:self.started] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLocationAuthorizationChanged object:self userInfo:info];
}


@end
