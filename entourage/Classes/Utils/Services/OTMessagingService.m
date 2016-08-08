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
//testing
#import "OTFeedItemMessage.h"
#import "OTFeedItemJoiner.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

@implementation OTMessagingService

- (void)readFor:(OTFeedItem *)feedItem withResultBlock:(void (^)(NSArray *))result {
    if(!result)
        return;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_async(group, queue, ^() {
        id<OTMessagingDelegate> messaging = [[OTFeedItemFactory createFor:feedItem] getMessaging];

        NSMutableArray *allItems = [NSMutableArray new];
        [allItems addObjectsFromArray:[messaging getTimelineStatusMessages]];
        
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        dispatch_group_notify(group, queue, ^ {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *sortedItems = [allItems sortedArrayUsingSelector:@selector(compare:)];
                result(sortedItems);
            });
        });
        
        [messaging getMessagesWithSuccess:^(NSArray *items) {
            @synchronized (allItems) {
                [allItems addObjectsFromArray:items];
            }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];

        [messaging getJoinRequestsWithSuccess:^(NSArray *items) {
            @synchronized (allItems) {
                [allItems addObjectsFromArray:items];
            }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];

        [messaging getEncountersWithSuccess:^(NSArray *items) {
            @synchronized (allItems) {
                [allItems addObjectsFromArray:items];
            }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
        }];
    });
}

@end
