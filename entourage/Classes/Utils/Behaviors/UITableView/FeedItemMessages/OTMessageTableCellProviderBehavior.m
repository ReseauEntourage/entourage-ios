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

@implementation OTMessageTableCellProviderBehavior

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTFeedItemTimelinePoint *timelinePoint = [self.tableDataSource getItemAtIndexPath:indexPath];
    NSString *reuseIdentifier = [self getReuseIdentifier:timelinePoint];

    OTChatCellBase *cell = (OTChatCellBase *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
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
        case MessageCellTypeJoinRequested:
            return @"JoinRequestedCell";
        case MessageCellTypeStatus:
            return @"StatusCell";
        default:
            return @"PlaceholderCell";
    }
}

@end
