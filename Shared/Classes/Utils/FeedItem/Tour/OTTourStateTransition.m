//
//  OTTourStateFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourStateTransition.h"
#import "OTTour.h"
#import "OTTourService.h"

@implementation OTTourStateTransition

- (void)stopWithSuccess:(void (^)(void))success orFailure:(void (^)(NSError *))failure {
    [[OTTourService new] closeTour:self.tour
                       withSuccess:^(OTTour *updatedTour) {
                           NSLog(@"Closed tour: %@", updatedTour.uid);
                           success();
                       } failure:^(NSError *error) {
                           NSLog(@"CLOSEerr %@", error.description);
                           if(failure)
                               failure(error);
                       }];
}

- (void)closeWithOutcome:(BOOL)outcome
              andComment:(NSString *) comment
                 success:(void (^)(BOOL))success
               orFailure:(void (^)(NSError *))failure
{
    NSString *oldStatus = self.tour.status;
    self.tour.status = TOUR_STATUS_FREEZED;
    [[OTTourService new] closeTour:self.tour
                       withSuccess:^(OTTour *updatedTour) {
                           NSLog(@"freezed tour: %@", updatedTour.uid);
                           success(YES);
                       } failure:^(NSError *error) {
                           NSLog(@"FREEZEerr %@", error.description);
                           self.tour.status = oldStatus;
                           if(failure)
                               failure(error);
                       }];
}

- (void)quitWithSuccess:(void (^)(void))success orFailure:(void (^)(NSError *))failure {
    NSString *oldJoinState = self.tour.joinStatus;
    self.tour.joinStatus = JOIN_NOT_REQUESTED;
    [[OTTourService new] quitTour:self.tour
                          success:^() {
                              NSLog(@"Quited tour: %@", self.tour.uid);
                              success();
                          } failure:^(NSError *error) {
                              NSLog(@"QUITerr %@", error.description);
                              self.tour.joinStatus = oldJoinState;
                              if(failure)
                                  failure(error);
                          }];
}

- (void)sendJoinRequest:(void (^)(OTFeedItemJoiner *))success orFailure:(void (^)(NSError *, BOOL))failure {
    NSString *oldJoinState = self.tour.joinStatus;
    self.tour.joinStatus = JOIN_PENDING;
    [[OTTourService new] joinTour:self.tour
        success:^(OTFeedItemJoiner *joiner) {
            NSLog(@"Sent tour join request: %@", self.tour.uid);
            success(joiner);
        } failure:^(NSError *error) {
            NSLog(@"Send tour join request error: %@", error.description);
            self.tour.joinStatus = oldJoinState;
            failure(error, YES);
        }];
}

@end
