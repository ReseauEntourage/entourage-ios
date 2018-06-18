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

@implementation OTMembersCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    id item = [self.tableDataSource getItemAtIndexPath:indexPath];
    NSString *identifier = [self cellIdentifierAtPath:indexPath forItem:item];
    
    if (identifier) {
        OTBaseInfoCell *cell = (OTBaseInfoCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:identifier];
        [cell configureWith:item];
        return cell;
    }
    
    UITableViewCell *emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return emptyCell;
}

#pragma mark - private methods

- (NSInteger)inviteCellIndex {
    BOOL hasFoundDescriptionItem = NO;
    for (id item in self.tableDataSource.dataSource.items) {
        if ([item isKindOfClass:[NSString class]]) {
            hasFoundDescriptionItem = YES;
            break;
        }
    }
    return hasFoundDescriptionItem ? 3 : 2;
}

- (NSString *)cellIdentifierAtPath:(NSIndexPath *)indexPath forItem:(id)item {
    NSInteger inviteCellIndex = [self inviteCellIndex];
    if ([item isKindOfClass:[NSString class]]) {
        return @"DescriptionCell";
    }
    else if ([item isKindOfClass:[OTFeedItemJoiner class]]) {
        return @"MemberCell";
    }
    else if (indexPath.row == inviteCellIndex) {
        return @"InviteCell";
    }
    else if (indexPath.row == 0) {
        return  @"MapCell";
        
    } else if (indexPath.row == inviteCellIndex - 1) {
        return  @"MemberCountCell";
    }
    
    return @"MemberCountCell";;
}

@end
