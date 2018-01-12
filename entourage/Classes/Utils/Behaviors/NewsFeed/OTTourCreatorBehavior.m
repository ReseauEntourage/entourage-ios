//
//  OTTourCreatorBehavior.m
//  entourage
//
//  Created by sergiu buceac on 10/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourCreatorBehavior.h"
#import "OTTour.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "OTTourService.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "OTOngoingTourService.h"
#import "OTTourPoint.h"
#import "NSUserDefaults+OT.h"

#define MIN_POINTS_TO_SEND 3
#define HOW_RECENT_THRESHOLD 120

@interface OTTourCreatorBehavior ()

@property (nonatomic, strong) NSMutableArray *tourPointsToSend;
@property (nonatomic, strong) CLLocation *lastLocation;

@end

@implementation OTTourCreatorBehavior

- (void)initialize {
    self.tourPointsToSend = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:kNotificationLocationUpdated object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startTour:(NSString*)tourType {
    if(![OTLocationManager sharedInstance].isAuthorized) {
        [[OTLocationManager sharedInstance] showGeoLocationNotAllowedMessage:OTLocalizedString(@"ask_permission_location_create_tour")];
        [self.delegate failedToStartTour];
        return;
    }
    else if(self.lastLocation == nil) {
            self.lastLocation = [OTLocationManager sharedInstance].currentLocation;
        }
    if(!self.lastLocation) {
        [[OTLocationManager sharedInstance] showLocationNotFoundMessage:OTLocalizedString(@"no_location_create_tour")];
        [self.delegate failedToStartTour];
        return;
    }
    
    [SVProgressHUD showWithStatus:OTLocalizedString(@"tour_create_sending")];
    self.tour = [[OTTour alloc] initWithTourType:tourType];
    self.tour.distance = @0.0;
    OTTourPoint *startPoint = [self addTourPointFromLocation:self.lastLocation toLastLocation:self.lastLocation];
    [self updateTourPointsToSendIfNeeded:startPoint];
    [[OTTourService new] sendTour:self.tour withSuccess:^(OTTour *sentTour) {
        self.tour = sentTour;
        self.tour.distance = @0.0;
        [self.tour.tourPoints addObject:startPoint];
        [self sendTourPointsWithSuccess:nil orFailure:nil];
        [self.delegate tourStarted];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"tour_create_error", @"")];
        NSLog(@"%@",[error localizedDescription]);
        self.tour = nil;
        [self.delegate failedToStartTour];
    }];
}

- (void)stopTour {
//    self.tourPointsToSend = self.tour.tourPoints;
//    if(self.tourPointsToSend.count == 0) {
//        [self.delegate stoppedTour];
//        return;
//    }
    OTTourPoint *lastTourPoint = self.tour.tourPoints.lastObject;
    if(self.tourPointsToSend.count > 0)
        lastTourPoint = self.tourPointsToSend.lastObject;
    CLLocation *lastLocationToSend = [self locationFromTourPoint:lastTourPoint];
    OTTourPoint *lastPoint = [self addTourPointFromLocation:self.lastLocation toLastLocation:lastLocationToSend];
    [self updateTourPointsToSendIfNeeded:lastPoint];
    [SVProgressHUD show];
    [self sendTourPointsWithSuccess:^() {
        [SVProgressHUD dismiss];
        [self.delegate stoppedTour];
    } orFailure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self.delegate failedToStopTour];
    }];
}

- (void)endOngoing {
    self.tour = nil;
    [self.tourPointsToSend removeAllObjects];
}

#pragma mark - private methods

- (void)locationUpdated:(NSNotification *)notification {
    NSArray *locations = [notification readLocations];
    for (CLLocation *newLocation in locations) {
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) > HOW_RECENT_THRESHOLD)
            continue;

        self.lastLocation = newLocation;
        if ([OTOngoingTourService sharedInstance].isOngoing) {
            CLLocation *lastDrawnTourLocation = [self locationFromTourPoint:self.tour.tourPoints.lastObject];
            OTTourPoint *addedPoint = [self addTourPointFromLocation:self.lastLocation
                                                      toLastLocation:lastDrawnTourLocation];
            CLLocation *lastLocationToSend = [self locationFromTourPoint:self.tourPointsToSend.lastObject];
            double distance = [self.lastLocation distanceFromLocation:lastLocationToSend];
            if (fabs(distance) > LOCATION_MIN_DISTANCE)
                [self updateTourPointsToSendIfNeeded:addedPoint];
            if (self.tour.tourPoints.count > MIN_POINTS_TO_SEND)
                [self sendTourPointsWithSuccess:nil orFailure:nil];
        }
    }
}

- (OTTourPoint *)addTourPointFromLocation:(CLLocation *)location toLastLocation:(CLLocation *)lastLocation {
    self.tour.distance = @(self.tour.distance.doubleValue + [location distanceFromLocation:lastLocation]);
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:46.777264 longitude:23.608863];
//    OTTourPoint *tourPoint2 = [[OTTourPoint alloc] initWithLocation:loc];
//    [self.tour.tourPoints addObject:tourPoint2];
    OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:location];
    [self.tour.tourPoints addObject:tourPoint];
    [[NSUserDefaults standardUserDefaults] setCurrentOngoingTour: nil];
    [[NSUserDefaults standardUserDefaults] setCurrentOngoingTour: self.tour];
    [[NSUserDefaults standardUserDefaults] synchronize];
    OTTour *t = [NSUserDefaults standardUserDefaults].currentOngoingTour;
    [self.delegate tourDataUpdated];
    return tourPoint;
}

- (void)updateTourPointsToSendIfNeeded:(OTTourPoint *)tourPoint {
    [self.tourPointsToSend addObject:tourPoint];
}

- (void)sendTourPointsWithSuccess:(void(^)())success orFailure:(void(^)(NSError *))failure {
    NSArray *sentPoints = [NSArray arrayWithArray:self.tour.tourPoints];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[OTTourService new] sendTourPoint:self.tour.tourPoints
                            withTourId:self.tour.uid
                           withSuccess:^(OTTour *updatedTour) {
        [self.tour.tourPoints removeObjectsInArray:sentPoints];
        [[NSUserDefaults standardUserDefaults] setCurrentOngoingTour:self.tour];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //[self.tourPointsToSend removeObjectsInArray:sentPoints];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (success)
            success();
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(failure)
            failure(error);
    }];
}

- (CLLocation *)locationFromTourPoint:(OTTourPoint *)tourPoint {
    return [[CLLocation alloc] initWithLatitude:tourPoint.latitude
                                      longitude:tourPoint.longitude];
}

@end
