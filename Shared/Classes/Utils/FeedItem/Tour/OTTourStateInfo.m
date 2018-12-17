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
    FeedItemState result = FeedItemStateNone;
    if ([TOUR_STATUS_ONGOING isEqualToString:self.tour.status])
        result = FeedItemStateOngoing;
    else if ([TOUR_STATUS_FREEZED isEqualToString:self.tour.status])
        return FeedItemStateFrozen;
    else
        result = FeedItemStateClosed;
    if ([currentUser.sid intValue] != [self.tour.author.uID intValue]) {
        if([JOIN_NOT_REQUESTED isEqualToString:self.tour.joinStatus] || [JOIN_CANCELLED isEqualToString:self.tour.joinStatus])
            result = FeedItemStateJoinNotRequested;
        else if([JOIN_ACCEPTED isEqualToString:self.tour.joinStatus])
            result = FeedItemStateJoinAccepted;
        else if([JOIN_PENDING isEqualToString:self.tour.joinStatus])
            result = FeedItemStateJoinPending;
        else if([JOIN_REJECTED isEqualToString:self.tour.joinStatus])
            result = FeedItemStateJoinRejected;
    }
    return result;
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

- (BOOL)isClosed {
    return [self.tour.status isEqualToString:TOUR_STATUS_FREEZED];
}

- (BOOL)isPublic {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([self.tour.status isEqualToString:TOUR_STATUS_FREEZED]) {
        return !([currentUser.sid intValue] == [self.tour.author.uID intValue] ||
                 [self.tour.joinStatus isEqualToString:JOIN_ACCEPTED]);
    }
    
    return ![JOIN_ACCEPTED isEqualToString:self.tour.joinStatus];
}

- (BOOL)canEdit {
    return NO;
}

- (BOOL)canCancelJoinRequest {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([currentUser.sid intValue] != [self.tour.author.uID intValue])
        return [self.tour.status isEqualToString:JOIN_PENDING];
    return NO;
}

- (void)loadWithSuccess:(void(^)(OTFeedItem *))success error:(void(^)(NSError *))failure {
    [[OTTourService new] getTourWithId:self.tour.uid withSuccess:^(OTTour *tour) {
        if(success)
            success(tour);
    } failure:^(NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)loadWithSuccess3:(void(^)(OTFeedItem *))success error:(void(^)(NSError *))failure {
    [[OTTourService new] getTourWithId:self.tour.uid withSuccess:^(OTTour *tour) {
        if(success)
            success(tour);
    } failure:^(NSError *error) {
        if(failure)
            failure(error);
    }];
}


@end
