//
//  OTMessageTableCellProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageTableCellProviderBehavior.h"
#import "OTMessageDataSourceBehavior.h"
#import "OTFeedItemTimelinePoint.h"

@implementation OTMessageTableCellProviderBehavior

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTFeedItemTimelinePoint *timelinePoint = [self.tableDataSource getItemAtIndexPath:indexPath];

    UITableViewCell *cell = [self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", timelinePoint.date];
    
    return cell;
}

@end
