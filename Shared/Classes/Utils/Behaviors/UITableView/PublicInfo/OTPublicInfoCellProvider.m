//
//  OTPublicInfoCellProvider.m
//  entourage
//
//  Created by sergiu buceac on 10/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicInfoCellProvider.h"
#import "OTBaseInfoCell.h"
#import "OTFeedItem.h"
#import "OTTableDataSourceBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTFeedItemJoiner.h"

@implementation OTPublicInfoCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    id item = [self.tableDataSource getItemAtIndexPath:indexPath];
    NSString *identifier = [self cellIdentifierAtPath:indexPath forItem:item];
    OTBaseInfoCell *cell = (OTBaseInfoCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:identifier];
    
    [cell configureWith:item];
    
    return cell;
}

#pragma mark - private methods

- (NSString *)cellIdentifierAtPath:(NSIndexPath *)indexPath forItem:(id)item {
    
    if ([item isKindOfClass:[OTFeedItem class]]) {
        OTFeedItem *feedItem = (OTFeedItem*)item;
        if ([feedItem.identifierTag isEqualToString:@"feedDescription"]) {
            return @"DescriptionCell";
        }
        else if ([feedItem.identifierTag isEqualToString:@"summary"]) {
            return @"SummaryCell";
        }
        else if ([feedItem.identifierTag isEqualToString:@"eventAuthorInfo"]) {
            return @"DescriptionCell";
        }
        else if ([feedItem.identifierTag isEqualToString:@"inviteFriend"]) {
            return @"InviteCell";
        }
        else if ([feedItem.identifierTag isEqualToString:@"feedLocation"]) {
            return  @"MapCell";
            
        } else if ([feedItem.identifierTag isEqualToString:@"membersCount"]) {
            return  @"MemberCountCell";
            
        } else if ([feedItem.identifierTag isEqualToString:@"eventInfo"]) {
            return  @"EventInfoCell";
        }
        else if ([feedItem.identifierTag isEqualToString:@"changeStatus"]) {
            return @"ChangeStatusCell";
        }
    }
    else if ([item isKindOfClass:[OTFeedItemJoiner class]]) {
        return @"MemberCell";
    }
    
    return @"MemberCountCell";
}

@end
