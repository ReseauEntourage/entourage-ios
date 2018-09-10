//
//  OTFeedsService.m
//  entourage
//
//  Created by Ciprian Habuc on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
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
                          success:(void (^)(NSMutableArray *feeds))success
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
             [self updateUnreadCount:feeds];
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
         [self updateUnreadCount:myFeeds];
         if (success)
             success(myFeeds);
     }
     andFailure:^(NSError *error)
     {
         if (failure)
             failure(error);
     }];
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

- (void)updateUnreadCount:(NSArray *)feeds {
    for (OTFeedItem *item in feeds) {
        item.unreadMessageCount = [[OTUnreadMessagesService sharedInstance] countUnreadMessages:item.uid stringId:item.uuid];
    }
}

@end
