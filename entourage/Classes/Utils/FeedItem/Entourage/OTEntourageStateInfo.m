//
//  OTEntourageStateInfo.m
//  entourage
//
//  Created by sergiu buceac on 6/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageStateInfo.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

@implementation OTEntourageStateInfo

- (FeedItemState)getEditNextState {
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.sid intValue] == [self.entourage.author.uID intValue]) {
        if ([ENTOURAGE_STATUS_OPEN isEqualToString:self.entourage.status])
            return FeedItemStateClosed;
    } else if([JOIN_ACCEPTED isEqualToString:self.entourage.joinStatus])
        return FeedItemStateQuit;
    return FeedItemStateNone;
}

- (FeedItemState)getFeedNextState {
    return 0;
}

- (BOOL)canChangeState {
    return ![self.entourage.status isEqualToString:FEEDITEM_STATUS_CLOSED];
}

@end
