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

@implementation OTTourStateInfo

- (FeedItemState)getState {
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
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
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.sid intValue] == [self.tour.author.uID intValue])
        return ![self.tour.status isEqualToString:TOUR_STATUS_FREEZED];
    return NO;
}

- (BOOL)canInvite {
    return NO;
}

@end
