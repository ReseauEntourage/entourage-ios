//
//  OTMembersCellProvider.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMembersCellProvider.h"
#import "OTFeedItemJoiner.h"
#import "OTTableDataSourceBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTMembersCell.h"

@implementation OTMembersCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTFeedItemJoiner *item = (OTFeedItemJoiner *)[self.tableDataSource getItemAtIndexPath:indexPath];
    
    OTMembersCell *cell = (OTMembersCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
    [cell configureWith:item];
    return cell;
}

@end
