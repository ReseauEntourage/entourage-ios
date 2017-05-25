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

- (void)addUnreadMessage:(NSNumber *)feedId {
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    OTUnreadMessageCount *unreadMessageFound = [self findIn:unreadMessages byFeedId:feedId];
    if(unreadMessageFound == nil) {
        unreadMessageFound = [OTUnreadMessageCount new];
        unreadMessageFound.unreadMessagesCount = [NSNumber numberWithInt:1];
        unreadMessageFound.feedId = feedId;
        [unreadMessages addObject:unreadMessageFound];
    }
    else{
        int value = [unreadMessageFound.unreadMessagesCount intValue];
        unreadMessageFound.unreadMessagesCount = @(value+1);
    }
    [self saveUnreadMessages:unreadMessages];
    NSDictionary* notificationInfo = @{ kNotificationUpdateBadgeCountKey:unreadMessageFound.unreadMessagesCount, kNotificationUpdateBadgeFeedIdKey:unreadMessageFound.feedId};
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateBadgeCountNotification object:notificationInfo];
}

- (void)removeUnreadMessages:(NSNumber *)feedId {
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    OTUnreadMessageCount *unreadMessageFound = [self findIn:unreadMessages byFeedId:feedId];
    if( unreadMessageFound != nil) {
        [unreadMessages removeObject:unreadMessageFound];
        [self saveUnreadMessages:unreadMessages];
    }
    NSDictionary* notificationInfo = @{ kNotificationUpdateBadgeCountKey: @(unreadMessages.count), kNotificationUpdateBadgeFeedIdKey:feedId};
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateBadgeCountNotification object:notificationInfo];
}

- (NSNumber *)countUnreadMessages:(NSNumber *)feedId {
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    OTUnreadMessageCount *unreadMessageFound = [self findIn:unreadMessages byFeedId:feedId];
        return unreadMessageFound == nil ? @(0) : unreadMessageFound.unreadMessagesCount;
    return @(0);
}

- (NSNumber *)totalCount {
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    int total = 0;
    for(OTUnreadMessageCount *item in unreadMessages)
        total += item.unreadMessagesCount.intValue;
    return @(total);
}

#pragma mark - private methods

- (NSString *)getUserKey {
    return [UserKey stringByAppendingString:USER_ID.stringValue];
}

- (OTUnreadMessageCount *)findIn:(NSArray *)array byFeedId:(NSNumber *)feedId {
    for(OTUnreadMessageCount *item in array) {
        if([item.feedId isEqualToNumber:feedId])
            return item;
    }
    return nil;
}

- (NSMutableArray *)getUnreadMessages {
    NSString *userKey = [self getUserKey];    
    NSMutableArray *unreadMessages = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:userKey]];
    if(unreadMessages==nil)
        unreadMessages = [NSMutableArray new];
    return unreadMessages;
}

- (void)saveUnreadMessages:(NSMutableArray *)unreadMessages {
    NSString *userKey = [self getUserKey];
     NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:unreadMessages];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:userKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
