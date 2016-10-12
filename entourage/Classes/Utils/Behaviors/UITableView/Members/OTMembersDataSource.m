//
//  OTMembersDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMembersDataSource.h"
#import "OTFeedItemFactory.h"
#import "SVProgressHUD.h"
#import "OTTableDataSourceBehavior.h"
#import "OTConsts.h"
#import "OTFeedItemFactory.h"

@implementation OTMembersDataSource

- (void)loadDataFor:(OTFeedItem *)feedItem {
    [SVProgressHUD show];
    NSMutableArray *newItems = [NSMutableArray new];
    [newItems addObject:feedItem];
    NSString *description = [[[OTFeedItemFactory createFor:feedItem] getUI] feedItemDescription];
    if([description length] > 0)
        [newItems addObject:description];
    [newItems addObject:feedItem];
    [self refreshTable:newItems];
    [[[OTFeedItemFactory createFor:feedItem] getMessaging] getFeedItemUsersWithStatus:JOIN_ACCEPTED success:^(NSArray *items) {
        [newItems addObjectsFromArray:items];
        [self refreshTable:newItems];
        [SVProgressHUD dismiss];
    } failure:^(NSError *failure) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - private methods

- (void)refreshTable:(NSArray *)newItems {
    [self updateItems:newItems];
    [self.tableDataSource refresh];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
