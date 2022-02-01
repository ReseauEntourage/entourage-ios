//
//  OTMembersTableDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTMembersTableDataSource.h"
#import "OTDataSourceBehavior.h"
#import "OTFeedItemJoiner.h"
#import "OTMemberCountCell.h"
#import "OTMembersCell.h"
#import "OTFeedItemFactory.h"

#define DEFAULT_LEFT_INSET 65

@interface OTMembersTableDataSource () <UITableViewDelegate>

@end

@implementation OTMembersTableDataSource

- (void)initialize {
    [super initialize];
    self.dataSource.tableView.tableFooterView = [UIView new];
    self.dataSource.tableView.delegate = self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
    
    if ([cell isKindOfClass:[OTMemberCountCell class]]) {
        insets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    else if ([cell isKindOfClass:[OTMembersCell class]]) {
        if (indexPath.row == self.dataSource.items.count - 1) {
            insets = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
        }
        else {
            insets = UIEdgeInsetsMake(0, DEFAULT_LEFT_INSET, 0, 0);
        }
    }
    cell.separatorInset = insets;
}

- (NSInteger)inviteCellIndex {
    BOOL hasFoundDescriptionItem = NO;
    for (OTFeedItem *item in self.dataSource.items) {
        if ([item.identifierTag isEqualToString:@"feedDescription"]) {
            hasFoundDescriptionItem = YES;
            break;
        }
    }
    return hasFoundDescriptionItem ? 3 : 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self getItemAtIndexPath:indexPath];
    
    if ([item isKindOfClass:[OTFeedItemJoiner class]]) {
        OTFeedItemJoiner *joiner = (OTFeedItemJoiner *)item;
        [self.userProfileBehavior showProfile:joiner.uID];
    }
    else if ([item isKindOfClass:[OTFeedItem class]]) {
        OTFeedItem *feedItem = (OTFeedItem*)item;
        if ([feedItem.identifierTag isEqualToString:@"inviteFriend"]) {
            id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:item] getStateInfo];
            if (![stateInfo canChangeEditState]) {
                return;
            }

            if ([stateInfo canInvite]) {
                [self.inviteBehavior startInvite];
            }
        }
    }
}

@end
