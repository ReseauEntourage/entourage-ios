//
//  OTMessagingDelegate.h
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemMessage.h"

@protocol OTMessagingDelegate <NSObject>

- (void)send:(NSString *)message withSuccess:(void (^)(OTFeedItemMessage *))success orFailure:(void (^)(NSError *))failure;
- (void)invitePhones:(NSArray *)phones withSuccess:(void (^)(void))success orFailure:(void (^)(NSError *, NSArray *failedNumbers))failure;
- (void)getMessagesWithSuccess:(void(^)(NSArray *))success failure:(void (^)(NSError *)) failure;
- (void)getFeedItemUsersWithStatus:(NSString *)status success:(void(^)(NSArray *))success failure:(void (^)(NSError *)) failure;
- (void)getEncountersWithSuccess:(void(^)(NSArray *))success failure:(void (^)(NSError *)) failure;
- (void)setMessagesAsRead:(void (^)(void))success orFailure:(void (^)(NSError *)) failure;
- (NSArray *)getTimelineStatusMessages;

@end
