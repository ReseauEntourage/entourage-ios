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
    
    if ([item isKindOfClass:[OTFeedItem class]]) {
        OTFeedItem *feedItem = (OTFeedItem*)item;
        if ([feedItem.identifierTag isEqualToString:@"feedDescription"]) {
            return @"DescriptionCell";
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
    }
    else if ([item isKindOfClass:[OTFeedItemJoiner class]]) {
        return @"MemberCell";
    }

    return @"MemberCountCell";
}

@end
