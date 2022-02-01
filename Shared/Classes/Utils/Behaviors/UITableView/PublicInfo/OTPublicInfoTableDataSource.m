//
//  OTPublicInfoTableDataSource.m
//  entourage
//
//  Created by sergiu buceac on 10/26/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTPublicInfoTableDataSource.h"
#import "OTDataSourceBehavior.h"
#import "OTFeedItemJoiner.h"
#import "OTMemberCountCell.h"
#import "OTMembersCell.h"
#import "OTFeedItemFactory.h"

@interface OTPublicInfoTableDataSource () <UITableViewDelegate>

@end

@implementation OTPublicInfoTableDataSource

- (void)initialize {
    [super initialize];
    self.dataSource.tableView.tableFooterView = [UIView new];
    self.dataSource.tableView.delegate = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self getItemAtIndexPath:indexPath];
    
    if ([item isKindOfClass:[OTFeedItemJoiner class]]) {
        OTFeedItemJoiner *joiner = (OTFeedItemJoiner *)item;
        [self.userProfileBehavior showProfile:joiner.uID];
    }
    else if ([item isKindOfClass:[OTFeedItem class]]) {
        OTFeedItem *feedItem = (OTFeedItem*)item;
        if ([feedItem.identifierTag isEqualToString:@"changeStatus"]) {
            [self.statusChangedBehavior startChangeStatus];
        }
        else if ([feedItem.identifierTag isEqualToString:@"inviteFriend"]) {
            id<OTStateInfoDelegate> stateInfo = [[OTFeedItemFactory createFor:item] getStateInfo];

            if ([stateInfo canInvite]) {
                [self.inviteBehavior startInvite];
            } else {
                [self.inviteBehavior.shareBehavior sharePublic:item];
            }
        }
    }
}

@end
