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
    if(unreadMessageFound == nil){
        OTUnreadMessageCount *unread = [OTUnreadMessageCount new];
        unread.unreadMessagesCount = [NSNumber numberWithInt:1];
        unread.feedId = feedId;
        [unreadMessages addObject:unread];
    }
    else{
        int value = [unreadMessageFound.unreadMessagesCount intValue];
        unreadMessageFound.unreadMessagesCount = @(value+1);
    }
    [self saveUnreadMessages:unreadMessages];
}

- (void)removeUnreadMessages:(NSNumber *)feedId {
    NSMutableArray *unreadMessages = [self getUnreadMessages];
    OTUnreadMessageCount *unreadMessageFound = [self findIn:unreadMessages byFeedId:feedId];
    if( unreadMessageFound != nil){
        [unreadMessages removeObject:unreadMessageFound];
        [self saveUnreadMessages:unreadMessages];
    }
}

- (NSNumber *)countUnreadMessages:(NSNumber *)feedId{
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
    return [UserKey stringByAppendingString:[NSUserDefaults standardUserDefaults].currentUser.sid.stringValue];
}

- (OTUnreadMessageCount *) findIn:(NSArray *)array byFeedId:(NSNumber *)feedId {
    for(OTUnreadMessageCount *item in array){
        if([item.feedId isEqualToNumber:feedId])
            return item;
    }
    return nil;
}

- (NSMutableArray *)getUnreadMessages {
    NSString *userKey = [self getUserKey];
    NSMutableArray *unreadMessages = [[NSUserDefaults standardUserDefaults] objectForKey:userKey];
    if(unreadMessages==nil)
        unreadMessages = [NSMutableArray new];
    return unreadMessages;
}

- (void)saveUnreadMessages: (NSMutableArray *) unreadMessages {
    NSString *userKey = [self getUserKey];
    [[NSUserDefaults standardUserDefaults] setObject:unreadMessages forKey:userKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
