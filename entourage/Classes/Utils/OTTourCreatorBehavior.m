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
#import "OTDebugLog.h"

#define REQUIRED_ACCURACY 20
#define MIN_POINTS_TO_SEND 3

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
    if(!self.lastLocation) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"failed_tour_start_no_location", @"")];
        [self.delegate failedToStartTour];
        return;
    }
    [SVProgressHUD showWithStatus:OTLocalizedString(@"tour_create_sending")];
    self.tour = [[OTTour alloc] initWithTourType:tourType];
    self.tour.distance = @0.0;
    OTTourPoint *startPoint = [self addTourPointFromLocation:self.lastLocation toLastLocation:self.lastLocation];
    [self updateTourPointsToSendIfNeeded:startPoint];
    [[OTTourService new] sendTour:self.tour withSuccess:^(OTTour *sentTour) {
        [[OTDebugLog sharedInstance] log:@"starting tour"];
        self.tour = sentTour;
        self.tour.distance = @0.0;
        [self.tour.tourPoints addObject:startPoint];
        [self.delegate tourStarted];
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [[OTDebugLog sharedInstance] log:@"failed to start tour"];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"tour_create_error", @"")];
        NSLog(@"%@",[error localizedDescription]);
        self.tour = nil;
        [self.delegate failedToStartTour];
    }];
}

- (void)stopTour {
    if(self.tourPointsToSend.count == 0) {
        [self.delegate stoppedTour];
        return;
    }
    OTTourPoint *lastTourPoint = self.tour.tourPoints.lastObject;
    if(self.tourPointsToSend.count > 0)
        lastTourPoint = self.tourPointsToSend.lastObject;
    CLLocation *lastLocationToSend = [self locationFromTourPoint:lastTourPoint];
    OTTourPoint *lastPoint = [self addTourPointFromLocation:self.lastLocation toLastLocation:lastLocationToSend];
    [self updateTourPointsToSendIfNeeded:lastPoint];
    [SVProgressHUD show];
    [self sendTourPointsWithSuccess:^() {
        [[OTDebugLog sharedInstance] log:@"sent points on stop"];
        [SVProgressHUD dismiss];
        [self.delegate stoppedTour];
    } orFailure:^(NSError *error) {
        [[OTDebugLog sharedInstance] log:@"failed to send points on stop"];
        [SVProgressHUD dismiss];
        [self.delegate failedToStopTour];
    }];
}

- (void)endOngoing {
    self.tour = nil;
    [self.tourPointsToSend removeAllObjects];
    [[OTDebugLog sharedInstance] sendEmail];
}

#pragma mark - private methods

- (void)locationUpdated:(NSNotification *)notification {
    NSArray *locations = [notification readLocations];
    for (CLLocation *newLocation in locations) {
        if (newLocation.horizontalAccuracy < REQUIRED_ACCURACY)
            self.lastLocation = newLocation;
        else
            continue;
        if([OTOngoingTourService sharedInstance].isOngoing) {
            CLLocation *lastDrawnTourLocation = [self locationFromTourPoint:self.tour.tourPoints.lastObject];
            OTTourPoint *addedPoint = [self addTourPointFromLocation:self.lastLocation toLastLocation:lastDrawnTourLocation];
            CLLocation *lastLocationToSend = [self locationFromTourPoint:self.tourPointsToSend.lastObject];
            double distance = [self.lastLocation distanceFromLocation:lastLocationToSend];
            if (fabs(distance) > LOCATION_MIN_DISTANCE)
                [self updateTourPointsToSendIfNeeded:addedPoint];
            if(self.tourPointsToSend.count > MIN_POINTS_TO_SEND)
                [self sendTourPointsWithSuccess:nil orFailure:nil];
        }
    }
}

- (OTTourPoint *)addTourPointFromLocation:(CLLocation *)location toLastLocation:(CLLocation *)lastLocation {
    self.tour.distance = @(self.tour.distance.doubleValue + [location distanceFromLocation:lastLocation]);
    OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:location];
    [self.tour.tourPoints addObject:tourPoint];
    [self.delegate tourDataUpdated];
    return tourPoint;
}

- (void)updateTourPointsToSendIfNeeded:(OTTourPoint *)tourPoint {
    [self.tourPointsToSend addObject:tourPoint];
}

- (void)sendTourPointsWithSuccess:(void(^)())success orFailure:(void(^)(NSError *))failure {
    NSArray *sentPoints = [NSArray arrayWithArray:self.tourPointsToSend];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[OTTourService new] sendTourPoint:self.tourPointsToSend withTourId:self.tour.uid withSuccess:^(OTTour *updatedTour) {
        for(OTTourPoint *point in sentPoints)
            [[OTDebugLog sharedInstance] log:[NSString stringWithFormat:@"sending point at %f,%f", point.latitude, point.longitude]];
        [self.tourPointsToSend removeObjectsInArray:sentPoints];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(success)
            success();
    } failure:^(NSError *error) {
        [[OTDebugLog sharedInstance] log:@"failed to send tour points"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(failure)
            failure(error);
    }];
}

- (CLLocation *)locationFromTourPoint:(OTTourPoint *)tourPoint {
    return [[CLLocation alloc] initWithLatitude:tourPoint.latitude longitude:tourPoint.longitude];
}

@end
