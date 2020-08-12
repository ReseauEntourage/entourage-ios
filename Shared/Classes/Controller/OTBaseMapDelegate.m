//
//  OTBaseMapDelegate.m
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBaseMapDelegate.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "NSUserDefaults+OT.h"

@interface OTBaseMapDelegate ()

@property (nonatomic) BOOL mapWasCenteredOnUserLocation;

@end

@implementation OTBaseMapDelegate

- (instancetype)initWithMapController:(OTMainViewController *)mapController {
    self = [super init];
    if (self) {
        self.mapController = mapController;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(locationUpdated:)
                                                     name:kNotificationLocationUpdated
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private methods

- (void)locationUpdated:(NSNotification *)notification {
    if (!self.mapWasCenteredOnUserLocation) {
        
        OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
        if ([currentUser hasActionZoneDefined] && currentUser.addressPrimary.location) {
            self.mapWasCenteredOnUserLocation = YES;
            [self.mapController zoomMapToLocation:currentUser.addressPrimary.location];
        } else {
            NSArray *locations = [notification readLocations];
            if (locations.count > 0) {
                self.mapWasCenteredOnUserLocation = YES;
                [self.mapController zoomToCurrentLocation:nil];
            }
        }
    }
}

@end
