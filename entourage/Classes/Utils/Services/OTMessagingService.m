//
//  OTMessagingService.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessagingService.h"
#import "OTFeedItemFactory.h"
#import "OTMessagingDelegate.h"

@implementation OTMessagingService

- (void)readFor:(OTFeedItem *)feedItem onDataSource:(OTDataSourceBehavior *)dataSource {
    if(!dataSource)
        return;
    
    [dataSource.items removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        id<OTMessagingDelegate> messaging = [[OTFeedItemFactory createFor:feedItem] getMessaging];

        NSMutableArray *allItems = [NSMutableArray new];
        [allItems addObjectsFromArray:[messaging getTimelineStatusMessages]];
        [self sendItems:allItems toSource:dataSource];
        
        [messaging getMessagesWithSuccess:^(NSArray *items) {
            if([items count] > 0)
                @synchronized (allItems) {
                    [allItems addObjectsFromArray:items];
                    [self sendItems:allItems toSource:dataSource];
                }
        } failure:nil];

        [messaging getFeedItemUsersWithStatus:nil success:^(NSArray *items) {
            if([items count] > 0)
                @synchronized (allItems) {
                    for(OTFeedItemJoiner *joiner in items)
                        joiner.feedItem = feedItem;
                    [allItems addObjectsFromArray:items];
                    [self sendItems:allItems toSource:dataSource];
                }
        } failure:nil];

        [messaging getEncountersWithSuccess:^(NSArray *items) {
            if([items count] > 0)
                @synchronized (allItems) {
                    [allItems addObjectsFromArray:items];
                    [self sendItems:allItems toSource:dataSource];
                }
        } failure:nil];
    });
}

#pragma mark - private methods

- (void)sendItems:(NSArray *)items toSource:(OTDataSourceBehavior *)source {
    NSArray *sortedItems = [items sortedArrayUsingSelector:@selector(compare:)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [source updateItems:sortedItems];
        [source.tableView reloadData];
    });
}

@end
