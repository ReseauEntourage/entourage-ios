//
//  OTUnreadMessagesService.m
//  entourage
//
//  Created by veronica.gliga on 15/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTUnreadMessagesService.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTUnreadMessageCount.h"
#import "OTConsts.h"
#import "OTAppDelegate.h"
#import "OTAPIConsts.h"
#import "OTAppConfiguration.h"

#define UserKey @"UserKey"

@implementation OTUnreadMessagesService

+ (OTUnreadMessagesService *)sharedInstance {
    static OTUnreadMessagesService* sharedInstance;
    static dispatch_once_t unreadMessageToken;
    dispatch_once(&unreadMessageToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)setTotalUnreadCount:(NSNumber *)count {
    NSDictionary* notificationInfo = @{kNotificationTotalUnreadCountKey:count};
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateTotalUnreadCountNotification object:notificationInfo];
}

- (void)setGroupUnreadMessagesCount:(NSNumber *)feedId stringId:(NSString*)stringId count:(NSNumber *)count {
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    OTUnreadMessageCount *unreadMessageFound = [self findIn:unreadMessages byFeedNumberId:feedId stringId:stringId];
    if (unreadMessageFound == nil) {
        unreadMessageFound = [OTUnreadMessageCount new];
        unreadMessageFound.feedId = feedId;
        unreadMessageFound.uuid = stringId;
        [unreadMessages addObject:unreadMessageFound];
    }

    unreadMessageFound.unreadMessagesCount = count;

    id feedUid = feedId ? feedId : stringId;
    
    [self saveUnreadMessages:unreadMessages];
    NSDictionary* notificationInfo = @{
        kNotificationUpdateBadgeCountKey:unreadMessageFound.unreadMessagesCount,
        kNotificationUpdateBadgeFeedIdKey:feedUid,
        kNotificationUpdateBadgeRefreshFeed:@NO
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupUnreadStateNotification object:notificationInfo];
}

- (void)incrementGroupUnreadMessagesCount:(NSNumber *)feedId stringId:(NSString*)stringId {
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    OTUnreadMessageCount *unreadMessageFound = [self findIn:unreadMessages byFeedNumberId:feedId stringId:stringId];
    if (unreadMessageFound == nil) {
        unreadMessageFound = [OTUnreadMessageCount new];
        unreadMessageFound.unreadMessagesCount = [NSNumber numberWithInt:1];
        unreadMessageFound.feedId = feedId;
        unreadMessageFound.uuid = stringId;
        [unreadMessages addObject:unreadMessageFound];
    }
    else{
        int value = [unreadMessageFound.unreadMessagesCount intValue];
        unreadMessageFound.unreadMessagesCount = @(value+1);
    }
    
    id feedUid = feedId ? feedId : stringId;
    
    [self saveUnreadMessages:unreadMessages];
    NSDictionary* notificationInfo = @{
        kNotificationUpdateBadgeCountKey:unreadMessageFound.unreadMessagesCount,
        kNotificationUpdateBadgeFeedIdKey:feedUid,
        kNotificationUpdateBadgeRefreshFeed:@YES
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupUnreadStateNotification object:notificationInfo];
}

- (void)setGroupAsRead:(NSNumber *)feedId stringId:(NSString*)stringId refreshFeed:(BOOL)refreshFeed {
    if (!feedId && !stringId) {
        return;
    }
    
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    OTUnreadMessageCount *unreadMessageFound = [self findIn:unreadMessages byFeedNumberId:feedId stringId:stringId];
    
    if (unreadMessageFound != nil) {
        [unreadMessages removeObject:unreadMessageFound];
        [self saveUnreadMessages:unreadMessages];
    }
    
    id feedUid = feedId ? feedId: stringId;
    
    NSDictionary *notificationInfo = @{
        kNotificationUpdateBadgeCountKey: @(unreadMessages.count),
        kNotificationUpdateBadgeFeedIdKey:feedUid,
        kNotificationUpdateBadgeRefreshFeed:@(refreshFeed)
    };

    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateGroupUnreadStateNotification object:notificationInfo];
    [self setTotalUnreadCount:self.totalCount];
}

- (NSNumber *)countUnreadMessages:(NSNumber *)feedId stringId:(NSString*)stringId {
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    OTUnreadMessageCount *unreadMessageFound = [self findIn:unreadMessages byFeedNumberId:feedId stringId: stringId];
    
        return unreadMessageFound == nil ? @(0) : unreadMessageFound.unreadMessagesCount;
    
    return @(0);
}

- (NSNumber *)totalCount {
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    int total = 0;
    for (OTUnreadMessageCount *item in unreadMessages) {
        if (item.unreadMessagesCount.intValue > 0) {
            total += 1;
        }
    }
    
    return @(total);
}

#pragma mark - private methods

- (NSString *)getUserKey {
    if (USER_UUID) {
        return [UserKey stringByAppendingString:USER_UUID];
    }
    
    return UserKey;
}

- (OTUnreadMessageCount *)findIn:(NSArray *)array
                  byFeedNumberId:(NSNumber *)feedId
                        stringId:(NSString*)stringId {
    if (array.count > 0) {
        for(OTUnreadMessageCount *item in array) {
            if (item.feedId && feedId && [item.feedId isEqualToNumber:feedId]) {
                return item;
                
            } else if (item.uuid && stringId && [item.uuid isEqualToString:stringId]) {
                return item;
            }
        }
    }
    
    return nil;
}

- (NSMutableArray *)getUnreadMessages {
    NSString *userKey = [self getUserKey];    
    NSMutableArray *unreadMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:userKey]];
    
    if (unreadMessages == nil) {
        unreadMessages = [NSMutableArray new];
    }
    
    return unreadMessages;
}

- (void)saveUnreadMessages:(NSMutableArray *)unreadMessages {
    NSString *userKey = [self getUserKey];
     NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:unreadMessages];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:userKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
