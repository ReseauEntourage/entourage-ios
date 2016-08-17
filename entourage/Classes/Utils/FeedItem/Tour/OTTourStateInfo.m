//
//  OTTourStateInfo.m
//  entourage
//
//  Created by sergiu buceac on 6/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourStateInfo.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTTourService.h"

@implementation OTTourStateInfo

- (FeedItemState)getState {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([currentUser.sid intValue] == [self.tour.author.uID intValue]) {
        if ([TOUR_STATUS_ONGOING isEqualToString:self.tour.status])
            return FeedItemStateOngoing;
        else if ([TOUR_STATUS_FREEZED isEqualToString:self.tour.status])
            return FeedItemStateFrozen;
        else
            return FeedItemStateClosed;
    }
    else {
        if([JOIN_NOT_REQUESTED isEqualToString:self.tour.joinStatus])
            return FeedItemStateJoinNotRequested;
        else if([JOIN_ACCEPTED isEqualToString:self.tour.joinStatus])
            return FeedItemStateJoinAccepted;
        else if([JOIN_PENDING isEqualToString:self.tour.joinStatus])
            return FeedItemStateJoinPending;
        else if([JOIN_REJECTED isEqualToString:self.tour.joinStatus])
            return FeedItemStateJoinRejected;
    }
    return FeedItemStateNone;
}

- (BOOL)canChangeEditState {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([currentUser.sid intValue] == [self.tour.author.uID intValue])
        return ![self.tour.status isEqualToString:TOUR_STATUS_FREEZED];
    return NO;
}

- (BOOL)canInvite {
    return NO;
}

- (BOOL)isActive {
    return [self.tour.status isEqualToString:TOUR_STATUS_ONGOING] || [self.tour.status isEqualToString:FEEDITEM_STATUS_CLOSED];
}

- (BOOL)isPublic {
    if([self.tour.status isEqualToString:TOUR_STATUS_FREEZED])
        return YES;
    return ![self.tour.joinStatus isEqualToString:JOIN_ACCEPTED];
}

- (void)loadById:(NSNumber *)feedItemId withSuccess:(void(^)(OTFeedItem *))success error:(void(^)(NSError *))failure {
    [[OTTourService new] getTourWithId:feedItemId withSuccess:^(OTTour *tour) {
        if(success)
            success(tour);
    } failure:^(NSError *error) {
        if(failure)
            failure(error);
    }];
}

@end
