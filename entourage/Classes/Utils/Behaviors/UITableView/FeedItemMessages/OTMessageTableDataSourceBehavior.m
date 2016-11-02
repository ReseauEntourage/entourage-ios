//
//  OTMessageTableDataSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageTableDataSourceBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTFeedItemTimelinePoint.h"
#import "OTFeedItemMessage.h"
#import "OTFeedItemJoiner.h"
#import "OTFeedItemStatus.h"
#import "OTEncounter.h"
#import "NSUserDefaults+OT.h"
#import "OTFeedItem.h"
#import "OTChatCellBase.h"
#import "OTUser.h"

@interface OTMessageTableDataSourceBehavior ()

@property (nonatomic, strong) OTUser *currentUser;

@end

@implementation OTMessageTableDataSourceBehavior

- (void)initialize {
    [super initialize];
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
}

- (MessageCellType)getCellType:(OTFeedItemTimelinePoint *)timelinePoint {
    if([timelinePoint class] == [OTFeedItemMessage class]) {
        OTFeedItemMessage * tMessage = (OTFeedItemMessage *)timelinePoint;
        return [self.currentUser.sid isEqual:tMessage.uID] ? MessageCellTypeSent : MessageCellTypeReceived;
    } else if([timelinePoint class] == [OTFeedItemJoiner class]) {
        OTFeedItemJoiner * tJoiner = (OTFeedItemJoiner *)timelinePoint;
        if([tJoiner.status isEqualToString:JOIN_ACCEPTED])
            return tJoiner.message.length > 0 ? MessageCellTypeReceived : MessageCellTypeJoinAccepted;
        else
            return [tJoiner.feedItem.author.uID isEqualToNumber:self.currentUser.sid] ? MessageCellTypeJoinRequested : MessageCellTypeJoinRequestedNotOwner;
    } else if([timelinePoint class] == [OTFeedItemJoiner class])
        return MessageCellTypeEncounter;
    else if([timelinePoint class] == [OTFeedItemStatus class])
        return MessageCellTypeStatus;
    else if([timelinePoint class] == [OTEncounter class])
        return MessageCellTypeEncounter;
    return MessageCellTypeNone;
}

@end
