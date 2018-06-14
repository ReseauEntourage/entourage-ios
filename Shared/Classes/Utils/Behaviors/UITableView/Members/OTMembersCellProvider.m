//
//  OTMembersCellProvider.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMembersCellProvider.h"
#import "OTTableDataSourceBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTBaseInfoCell.h"
#import "OTFeedItemJoiner.h"
#import "entourage-Swift.h"

#define INVITE_CELL_INDEX 3

@implementation OTMembersCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    id item = [self.tableDataSource getItemAtIndexPath:indexPath];
    NSString *identifier = [self cellIdentifierAtPath:indexPath forItem:item];
    OTBaseInfoCell *cell = (OTBaseInfoCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configureWith:item];
    return cell;
}

#pragma mark - private methods

- (NSString *)cellIdentifierAtPath:(NSIndexPath *)indexPath forItem:(id)item {
    if ([item isKindOfClass:[NSString class]]) {
        return @"DescriptionCell";
    }
    else if ([item isKindOfClass:[OTFeedItemJoiner class]]) {
        return @"MemberCell";
    }
    else if(indexPath.row == INVITE_CELL_INDEX) {
        return @"InviteCell";
    }
    else {
        return indexPath.row == 0 ? @"MapCell" : @"MemberCountCell";
    }
}

@end
