//
//  OTEntourageMessaging.m
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageMessaging.h"
#import "OTEntourageService.h"
#import "OTInvitationsService.h"
#import "OTFeedItemStatus.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

@implementation OTEntourageMessaging

- (void)send:(NSString *)message withSuccess:(void (^)(OTFeedItemMessage *))success orFailure:(void (^)(NSError *))failure {
    [[OTEntourageService new] sendMessage:message
                              onEntourage:self.entourage
                                  success:^(OTFeedItemMessage * tourMessage) {
                                      NSLog(@"CHAT %@", message);
                                      if (success) {
                                          success(tourMessage);
                                      }
        } failure:^(NSError *error) {
            NSLog(@"CHATerr: %@", error.description);
            if (failure) {
                failure(error);
            }
    }];
}

- (void)invitePhones:(NSArray *)phones
         withSuccess:(void (^)(void))success
           orFailure:(void (^)(NSError *, NSArray *))failure {
    [[OTInvitationsService new] inviteNumbers:phones
                                  toEntourage:self.entourage
                                      success:^() {
                                          NSLog(@"INVITE BY PHONES");
                                          if (success) {
                                              success();
                                          }
    } failure:^(NSError *error, NSArray* failedNumbers) {
        NSLog(@"ERROR INVITE BY PHONE %@", error.description);
        if (failure) {
            failure(error, failedNumbers);
        }
    }];
}

- (void)getMessagesWithSuccess:(void (^)(NSArray *))success
                       failure:(void (^)(NSError *))failure {
    [[OTEntourageService new] entourageMessagesForEntourage:self.entourage.uuid WithSuccess:^(NSArray *items) {
        NSLog(@"GET ENTOURAGE MESSAGES");
        if (success) {
            success(items);
        }
    } failure:^(NSError *error) {
        NSLog(@"GET ENTOURAGE MESSAGESErr: %@", error.description);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getFeedItemUsersWithStatus:(NSString *)status
                           success:(void(^)(NSArray *))success
                           failure:(void (^)(NSError *)) failure {
    [[OTEntourageService new] getUsersForEntourageWithId:self.entourage.uuid
                                                     uid:self.entourage.uid
                                                 success:^(NSArray *items) {
        NSLog(@"GET ENTOURAGE JOINS");
        if (success) {
            NSArray *filteredItems = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(OTFeedItemJoiner *item, NSDictionary *bindings) {
                return !status || [item.status isEqualToString:status];
            }]];
            success(filteredItems);
        }
    } failure:^(NSError *error) {
        NSLog(@"GET ENTOURAGE JOINSErr: %@", error.description);
        if(failure)
            failure(error);
    }];
}

- (void)getEncountersWithSuccess:(void (^)(NSArray *))success
                         failure:(void (^)(NSError *))failure {
    if (success) {
        success([NSArray new]);
    }
}

- (void)setMessagesAsRead:(void (^)(void))success
                orFailure:(void (^)(NSError *))failure {
    [[OTEntourageService new] readEntourageMessages:self.entourage.uuid success:^() {
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (NSArray *)getTimelineStatusMessages {
    return [NSArray new];
}

@end
