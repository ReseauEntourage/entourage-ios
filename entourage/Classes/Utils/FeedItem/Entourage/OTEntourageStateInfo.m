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

- (FeedItemState)getActionableState {
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.sid intValue] == [self.entourage.author.uID intValue]) {
        NSLog(@"status>>> %@", self.entourage.status);
        if ([self.entourage.status isEqualToString:ENTOURAGE_STATUS_OPEN])
            return FeedItemStateClosed;
    } else {
        return FeedItemStateQuit;
    }
    return FeedItemStateNone;
}

- (BOOL)canChangeState {
    return ![self.entourage.status isEqualToString:FEEDITEM_STATUS_CLOSED];
}

@end
