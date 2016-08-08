//
//  OTEntourageMessaging.m
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageMessaging.h"
#import "OTEntourageService.h"
#import "OTFeedItemStatus.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

@implementation OTEntourageMessaging

- (void)send:(NSString *)message withSuccess:(void (^)(OTFeedItemMessage *))success orFailure:(void (^)(NSError *))failure {
    [[OTEntourageService new] sendMessage:message onEntourage:self.entourage success:^(OTFeedItemMessage * tourMessage) {
            NSLog(@"CHAT %@", message);
            if(success)
                success(tourMessage);
        } failure:^(NSError *error) {
            NSLog(@"CHATerr: %@", error.description);
            if(failure)
                failure(error);
    }];
}

- (void)invitePhones:(NSArray *)phones withSuccess:(void (^)())success orFailure:(void (^)(NSError *, NSArray *))failure {
    [[OTEntourageService new] inviteNumbers:phones toEntourage:self.entourage success:^() {
        NSLog(@"INVITE BY PHONES");
        if(success)
            success();
    } failure:^(NSError *error, NSArray* failedNumbers) {
        NSLog(@"ERROR INVITE BY PHONE %@", error.description);
        if(failure)
            failure(error, failedNumbers);
    }];
}

- (void)getMessagesWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    [[OTEntourageService new] entourageMessagesForEntourage:self.entourage.uid WithSuccess:^(NSArray *items) {
        NSLog(@"GET ENTOURAGE MESSAGES");
        if(success)
            success(items);
    } failure:^(NSError *error) {
        NSLog(@"GET ENTOURAGE MESSAGESErr: %@", error.description);
        if(failure)
            failure(error);
    }];
}

- (void)getJoinRequestsWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    [[OTEntourageService new] entourageUsersJoins:self.entourage success:^(NSArray *items) {
        NSLog(@"GET ENTOURAGE JOINS");
        if(success) {
            NSNumber *currentUserId = [NSUserDefaults standardUserDefaults].currentUser.sid;
            NSArray *filteredItems = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(OTFeedItemJoiner *item, NSDictionary *bindings) {
                return ![item.uID isEqual:currentUserId] && ![item.status isEqualToString:JOIN_REJECTED];
            }]];
            success(filteredItems);
        }
    } failure:^(NSError *error) {
        NSLog(@"GET ENTOURAGE JOINSErr: %@", error.description);
        if(failure)
            failure(error);
    }];
}

- (void)getEncountersWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    if(success)
        success([NSArray new]);
}

- (NSArray *)getTimelineStatusMessages {
    OTFeedItemStatus *status = [OTFeedItemStatus new];
    status.date = self.entourage.creationDate;
    status.type = OTFeedItemStatusStart;
    status.status = [NSString stringWithFormat: OTLocalizedString(@"formatter_feed_item_status_ongoing"), [[[OTFeedItemFactory createFor:self.entourage] getUI] navigationTitle]];
    NSDate *now = [NSDate date];
    status.duration = [now timeIntervalSinceDate:self.entourage.creationDate];
    status.distance = 0;
    status.uID = self.entourage.uid;
    
    return @[status];
}

@end
