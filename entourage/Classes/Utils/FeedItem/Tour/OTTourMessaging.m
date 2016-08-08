//
//  OTTourMessaging.m
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourMessaging.h"
#import "OTTourService.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTFeedItemStatus.h"
#import "OTConsts.h"

@implementation OTTourMessaging

- (void)send:(NSString *)message withSuccess:(void (^)(OTFeedItemMessage *))success orFailure:(void (^)(NSError *))failure {
    [[OTTourService new] sendMessage:message onTour:self.tour success:^(OTFeedItemMessage * tourMessage) {
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
    // NOT IN THS VERSION (maybe 2.0)
}

- (void)sendJoinMessage:(NSString *)message success:(void (^)(OTFeedItemJoiner *))success failure:(void (^)(NSError *))failure {
    [[OTTourService new] joinMessageTour:self.tour message:message success:^(OTFeedItemJoiner *joiner) {
            NSLog(@"JOIN MESSAGE %@", message);
            if(success)
                success(joiner);
        } failure:^(NSError *error) {
            NSLog(@"JOIN MESSAGEerr: %@", error.description);
            if(failure)
                failure(error);
    }];
}

- (void)getMessagesWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    [[OTTourService new] tourMessages:self.tour success:^(NSArray *items) {
        NSLog(@"GET TOUR MESSAGES");
        if(success)
            success(items);
    } failure:^(NSError *error) {
        NSLog(@"GET TOUR MESSAGESErr: %@", error.description);
        if(failure)
            failure(error);
    }];
}

- (void)getJoinRequestsWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    [[OTTourService new] tourUsersJoins:self.tour success:^(NSArray *items) {
        NSLog(@"GET TOUR JOINS");
        if(success) {
            NSNumber *currentUserId = [NSUserDefaults standardUserDefaults].currentUser.sid;
            NSArray *allExceptCurrentUser = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(OTFeedItemJoiner *item, NSDictionary *bindings) {
                return ![item.uID isEqual:currentUserId];
            }]];
            success(items);
        }
    } failure:^(NSError *error) {
        NSLog(@"GET TOUR JOINSErr: %@", error.description);
        if(failure)
            failure(error);
    }];
}

- (void)getEncountersWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    [[OTTourService new] tourEncounters:self.tour success:^(NSArray *items) {
        NSLog(@"GET TOUR ENCOUNTERS");
        if(success)
            success(items);
    } failure:^(NSError *error) {
        NSLog(@"GET TOUR ENCOUNTERSErr: %@", error.description);
        if(failure)
            failure(error);
    }];
}

- (NSArray *)getTimelineStatusMessages {
    OTFeedItemStatus *start = [OTFeedItemStatus new];
    start.date = self.tour.creationDate;
    start.type = OTFeedItemStatusStart;
    start.status = [NSString stringWithFormat: OTLocalizedString(@"formatter_feed_item_status_ongoing"), [[[OTFeedItemFactory createFor:self.tour] getUI] navigationTitle]];
    NSDate *now = [NSDate date];
    start.duration = [now timeIntervalSinceDate:self.tour.creationDate];
    start.distance = 0;
    
    OTFeedItemStatus *end = [OTFeedItemStatus new];
    end.date = self.tour.endTime;
    end.type = OTFeedItemStatusEnd;
    end.status = OTLocalizedString(@"tour_status_completed");
    end.duration = [self.tour.endTime timeIntervalSinceDate:self.tour.creationDate];
    end.distance = self.tour.distance.doubleValue;
    
    return @[start, end];
}

@end
