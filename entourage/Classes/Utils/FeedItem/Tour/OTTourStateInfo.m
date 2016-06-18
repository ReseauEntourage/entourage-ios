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

- (FeedItemState)getEditNextState {
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.sid intValue] == [self.tour.author.uID intValue]) {
        if ([TOUR_STATUS_ONGOING isEqualToString:self.tour.status])
            return FeedItemStateClosed;
        else
            return FeedItemStateFrozen;
    } else if([JOIN_ACCEPTED isEqualToString:self.tour.joinStatus])
        return FeedItemStateQuit;
    return FeedItemStateNone;
}

- (FeedItemState)getFeedNextState {
    return 0;
}

- (BOOL)canChangeState {
    return ![self.tour.status isEqualToString:TOUR_STATUS_FREEZED];
}

@end
