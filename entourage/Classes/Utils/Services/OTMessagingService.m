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
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        id<OTMessagingDelegate> messaging = [[OTFeedItemFactory createFor:feedItem] getMessaging];

        NSMutableArray *allItems = [NSMutableArray new];
        [allItems addObjectsFromArray:[messaging getTimelineStatusMessages]];
        
        dispatch_group_enter(group);
        [messaging getMessagesWithSuccess:^(NSArray *items) {
            if([items count] > 0)
                @synchronized (allItems) {
                    [allItems addObjectsFromArray:items];
                }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];

        dispatch_group_enter(group);
        [messaging getFeedItemUsersWithStatus:nil success:^(NSArray *items) {
            if([items count] > 0)
                @synchronized (allItems) {
                    for(OTFeedItemJoiner *joiner in items)
                        joiner.feedItem = feedItem;
                    [allItems addObjectsFromArray:items];
                }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];

        dispatch_group_enter(group);
        [messaging getEncountersWithSuccess:^(NSArray *items) {
            if([items count] > 0)
                @synchronized (allItems) {
                    [allItems addObjectsFromArray:items];
                }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [self sendItems:allItems toSource:dataSource];
        });
    });
}

#pragma mark - private methods

- (void)sendItems:(NSArray *)items toSource:(OTDataSourceBehavior *)source {
   NSArray *sortedItems = [self insertChatDates:items];
    dispatch_async(dispatch_get_main_queue(), ^{
        [source updateItems:sortedItems];
        [source.tableView reloadData];
        if(source.items.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:source.items.count - 1 inSection:0];
            [source.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    });
}

- (NSArray *)insertChatDates:(NSArray *)items {
    NSArray *sortedItems = [items sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *result = [NSMutableArray new];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    for(OTFeedItemTimelinePoint *item in sortedItems){
        if(![self isDay:item.date SameDayAs:date]){
            date = item.date;
            OTFeedItemTimelinePoint *chatPoint = [OTFeedItemTimelinePoint new];
            chatPoint.date = date;
           [result addObject:chatPoint];
        }
        [result addObject:item];
    }
    return result;
}

- (BOOL)isDay: (NSDate *)date1 SameDayAs: (NSDate *) date2 {
    return [[NSCalendar currentCalendar] isDate:date1 inSameDayAsDate:date2];
}

@end
