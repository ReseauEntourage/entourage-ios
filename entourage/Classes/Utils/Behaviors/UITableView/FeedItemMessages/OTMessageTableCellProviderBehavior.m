//
//  OTMessageTableCellProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageTableCellProviderBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTFeedItemTimelinePoint.h"
#import "OTChatCellBase.h"
#import "OTFeedItemMessage.h"
#import "OTFeedItemJoiner.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

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
    NSNumber *userId = [NSUserDefaults standardUserDefaults].currentUser.sid;
    if([timelinePoint class] == [OTFeedItemMessage class]) {
        OTFeedItemMessage *msgTimeline = (OTFeedItemMessage *)timelinePoint;
        return [msgTimeline.uID isEqual:userId] ? @"MessageSentCell" : @"MessageReceivedCell";
    }
    else if ([timelinePoint class] == [OTFeedItemJoiner class])
        return @"JoinRequestedCell";
    return @"PlaceholderCell";
}

@end
