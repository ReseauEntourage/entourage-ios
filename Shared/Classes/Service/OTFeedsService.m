//
//  OTFeedsService.m
//  entourage
//
//  Created by Ciprian Habuc on 19/05/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTFeedsService.h"
#import "OTHTTPRequestManager.h"
#import "OTAPIConsts.h"
#import "OTAPIKeys.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTFeedItem.h"
#import "OTEntourage.h"
#import "OTTour.h"
#import "OTAnnouncement.h"
#import "OTUnreadMessagesService.h"

@implementation OTFeedsService

- (void)getAllFeedsWithParameters:(NSDictionary*)parameters
                          success:(void (^)(NSMutableArray *feeds, NSString *pageToken))success
                          failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_FEEDS, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
         GETWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSMutableArray *feeds = [self feedItemsFromDictionary:data];
             NSString *nextPageToken = [responseObject objectForKey:kWSKeyNextPageToken];
             // [self updateGroupsUnreadStates:feeds];
             [self updateTotalUnreadCount:data];
             if (success)
             {
                 success(feeds, nextPageToken);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure)
             {
                 failure(error);
             }
         }
     ];
}

- (void)getEventsWithParameters:(NSDictionary*)parameters
                        success:(void (^)(NSMutableArray *feeds))success
                        failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_EVENTS, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSMutableArray *feeds = [self feedItemsFromDictionary:data];
         // [self updateGroupsUnreadStates:feeds];
         if (success)
         {
             success(feeds);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }
     ];
}

- (void)getMyFeedsWithParameters:(NSDictionary*)parameters success:(void (^)(NSArray *entourages))success failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_MYFEEDS, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject)
     {
         NSDictionary *data = responseObject;
         NSMutableArray *myFeeds = [self feedItemsFromDictionary:data];
         [self updateGroupsUnreadStates:myFeeds];
         [self updateTotalUnreadCount:data];
         if (success)
             success(myFeeds);
     }
     andFailure:^(NSError *error)
     {
         if (failure)
             failure(error);
     }];
}

- (void)getSearchEntouragesWithParameters:(NSDictionary*)parameters
                          success:(void (^)(NSMutableArray *feeds, NSString *pageToken))success
                          failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_SEARCH_ENTOURAGES, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
         GETWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject)
         {
             NSDictionary *data = responseObject;
             NSMutableArray *feeds = [self entouragesItemsFromDictionary:data];
             NSString *nextPageToken = [responseObject objectForKey:kWSKeyNextPageToken];

        
             if (success) {
                 success(feeds, nextPageToken);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure) {
                 failure(error);
             }
         }
     ];
}

- (void)getEntouragesOwnedWithsuccess:(void (^)(NSMutableArray *feeds))success
                              failure:(void (^)(NSError *error))failure {
    NSString *url = [NSString stringWithFormat:API_URL_ENTOURAGE_OWNS, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:url
     andParameters:nil
     andSuccess:^(id responseObject) {
        NSDictionary *data = responseObject;
        NSMutableArray *feeds = [self entouragesItemsFromDictionary:data];
        
        if (success) {
            success(feeds);
        }
    }
     andFailure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }
    ];
}

#pragma mark - private methods

- (NSMutableArray *)feedItemsFromDictionary:(NSDictionary *)dictionary {
    NSMutableArray *feedItems = [[NSMutableArray alloc] init];
    NSArray *feedsDictionaries = [dictionary objectForKey:kWSKeyFeeds];
    for (NSDictionary *dictionary in feedsDictionaries) {
        NSString *feedType = [dictionary valueForKey:kWSKeyType];
        NSDictionary *feedItemDictionary = [dictionary objectForKey:kWSKeyData];
        OTFeedItem *feedItem;
        if ([feedType isEqualToString:@"Entourage"])
            feedItem = [[OTEntourage alloc] initWithDictionary:feedItemDictionary];
        else if ([feedType isEqualToString:@"Tour"])
            feedItem = [[OTTour alloc] initWithDictionary:feedItemDictionary];
        else if ([feedType isEqualToString:@"Announcement"])
            feedItem = [[OTAnnouncement alloc] initWithDictionary:feedItemDictionary];
        if(feedItem)
            [feedItems addObject:feedItem];
    }
    return feedItems;
}

- (NSMutableArray *)entouragesItemsFromDictionary:(NSDictionary *)dictionary {
    NSMutableArray *feedItems = [[NSMutableArray alloc] init];
    NSArray *feedsDictionaries = [dictionary objectForKey:@"entourages"];
    for (NSDictionary *dictionary in feedsDictionaries) {
        OTFeedItem * feedItem = [[OTEntourage alloc] initWithDictionary:dictionary];
       [feedItems addObject:feedItem];
    }
    return feedItems;
}

- (void)updateGroupsUnreadStates:(NSArray *)feeds {
    for (OTFeedItem *item in feeds) {
        [[OTUnreadMessagesService sharedInstance] setGroupUnreadMessagesCount:item.uid stringId:item.uuid count:item.unreadMessageCount];
    }
}

- (void)updateTotalUnreadCount:(NSDictionary *)data {
    NSNumber *totalUnreadCount = [data numberForKey:@"unread_count"];
    if (totalUnreadCount) {
        [[OTUnreadMessagesService sharedInstance] setTotalUnreadCount:totalUnreadCount];
    }
}

@end
