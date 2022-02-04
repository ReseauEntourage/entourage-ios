//
//  OTMessagingService.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTMessagingService.h"
#import "OTFeedItemFactory.h"
#import "OTMessagingDelegate.h"
#import "OTUser.h"
#import "OTFeedItemAuthor.h"
#import "NSUserDefaults+OT.h"

@implementation OTMessagingService

- (void)readFor:(OTFeedItem *)feedItem onDataSource:(OTDataSourceBehavior *)dataSource {
    if (!dataSource) {
        return;
    }
    
    id<OTMessagingDelegate> messaging = [[OTFeedItemFactory createFor:feedItem] getMessaging];

    NSMutableArray *allItems = [NSMutableArray new];
    [allItems addObjectsFromArray:[messaging getTimelineStatusMessages]];
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_group_enter(group);
    dispatch_group_enter(group);

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self sendItems:allItems toSource:dataSource];
    });

    [messaging getMessagesWithSuccess:^(NSArray *items) {
        if([items count] > 0)
            @synchronized (allItems) {
                [allItems addObjectsFromArray:items];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateViewReport" object:nil];
            }
        dispatch_group_leave(group);
    } failure:^(NSError *error) {
        dispatch_group_leave(group);
    }];

    // EMA-2425
//    if ([[[OTFeedItemFactory createFor: feedItem] getStateInfo] isClosed]) {
//        dispatch_group_leave(group);
//    }
//    else
    {
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
    }
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    OTFeedItemAuthor *author = feedItem.author;
    if (currentUser != nil && author != nil) {
        if([currentUser.sid isEqualToNumber:author.uID]) {
            [messaging getEncountersWithSuccess:^(NSArray *items) {
                if([items count] > 0)
                    @synchronized (allItems) {
                        [allItems addObjectsFromArray:items];
                    }
             dispatch_group_leave(group);
             } failure:^(NSError *error) {
                 dispatch_group_leave(group);
             }];
        } else {
            dispatch_group_leave(group);
        }
    }
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
        if(![[NSCalendar currentCalendar] isDate:item.date inSameDayAsDate:date]) {
            date = item.date;
            OTFeedItemTimelinePoint *chatPoint = [OTFeedItemTimelinePoint new];
            chatPoint.date = date;
            [result addObject:chatPoint];
        }
        [result addObject:item];
    }
    return result;
}

@end
