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
#import "OTUser.h"
#import "OTFeedItem.h"
#import "OTChatCellBase.h"

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
        return [tJoiner.status isEqualToString:JOIN_ACCEPTED] ? MessageCellTypeJoinAccepted : MessageCellTypeJoinRequested;
    } else if([timelinePoint class] == [OTFeedItemJoiner class])
        return MessageCellTypeEncounter;
    else if([timelinePoint class] == [OTFeedItemStatus class])
        return MessageCellTypeStatus;
    else if([timelinePoint class] == [OTEncounter class])
        return MessageCellTypeEncounter;
    return MessageCellTypeNone;
}

@end
