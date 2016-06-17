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
