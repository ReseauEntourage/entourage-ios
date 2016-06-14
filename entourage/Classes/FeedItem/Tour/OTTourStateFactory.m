//
//  OTTourStateFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourStateFactory.h"
#import "OTTour.h"
#import "OTTourService.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

@implementation OTTourStateFactory

- (void)closeWithSuccess:(void (^)())success {
    [[OTTourService new] closeTour:self.tour
                       withSuccess:^(OTTour *updatedTour) {
                           NSLog(@"Closed tour: %@", updatedTour.uid);
                           success();
                       } failure:^(NSError *error) {
                           NSLog(@"CLOSEerr %@", error.description);
                       }];
}

- (void)freezeWithSuccess:(void (^)())success {
    self.tour.status = TOUR_STATUS_FREEZED;
    [[OTTourService new] closeTour:self.tour
                       withSuccess:^(OTTour *updatedTour) {
                           NSLog(@"freezed tour: %@", updatedTour.uid);
                           success();
                       } failure:^(NSError *error) {
                           NSLog(@"FREEZEerr %@", error.description);
                       }];
}

- (void)quitWithSuccess:(void (^)())success {
    [[OTTourService new] quitTour:self.tour
                          success:^() {
                              NSLog(@"Quited tour: %@", self.tour.uid);
                              success();
                          } failure:^(NSError *error) {
                              NSLog(@"QUITerr %@", error.description);
                          }];
}

- (FeedItemState)getActionableState {
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.sid intValue] == [self.tour.author.uID intValue]) {
        if ([self.tour.status isEqualToString:TOUR_STATUS_ONGOING])
            return FeedItemStateClosed;
        else
            return FeedItemStateFrozen;
    } else {
        return FeedItemStateQuit;
    }
}

- (BOOL)canChangeState {
    return ![self.tour.status isEqualToString:TOUR_STATUS_FREEZED];
}

@end
