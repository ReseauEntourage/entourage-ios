//
//  OTMessageTableCellProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageTableCellProviderBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTMessageTableDataSourceBehavior.h"
#import "OTFeedItemTimelinePoint.h"
#import "OTChatCellBase.h"
#import "MessageCellType.h"
#import "OTEncounterCell.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

@implementation OTMessageTableCellProviderBehavior

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTFeedItemTimelinePoint *timelinePoint = [self.tableDataSource getItemAtIndexPath:indexPath];
    NSString *reuseIdentifier = [self getReuseIdentifier:timelinePoint];
    OTChatCellBase *cell = (OTChatCellBase *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if ([cell isKindOfClass:[OTEncounterCell class]]) {
        ((OTEncounterCell *)cell).feedItem = self.feedItem;
    }
    
    [cell configureWithTimelinePoint:timelinePoint];
    
    return cell;
}

#pragma mark - private methods

- (NSString *)getReuseIdentifier:(OTFeedItemTimelinePoint *)timelinePoint {
    MessageCellType cellType = [(OTMessageTableDataSourceBehavior *)self.tableDataSource getCellType:timelinePoint];
    switch (cellType) {
        case MessageCellTypeSent:
            return @"MessageSentCell";
        case MessageCellTypeReceived:
            return @"MessageReceivedCell";
        case MessageCellTypeJoinAccepted:
            return @"JoinAcceptedCell";
        case MessageCellTypeJoinRejected:
            return @"JoinRejectedCell";
        case MessageCellTypeJoinRequested:
            return @"JoinRequestedCell";
        case MessageCellTypeJoinRequestedNotOwner:
            return @"JoinRequestedNotOwnerCell";
        case MessageCellTypeStatus:
            return @"StatusCell";
        case MessageCellTypeEncounter:
            return @"EncounterCell";
        case MessageCellTypeChatDate:
            return @"ChatDateCell";
        case MessageCellTypeEventCreated:
            return @"EventCreatedCell";
        case MessageCellTypeItemClosed:
            return @"FeedClosedCell";
        default:
            return @"PlaceholderCell";
    }
}

@end
