//
//  OTEntourageMessaging.m
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageMessaging.h"
#import "OTEntourageService.h"

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

- (void)sendJoinMessage:(NSString *)message success:(void (^)(OTFeedItemJoiner *))success failure:(void (^)(NSError *))failure {
    [[OTEntourageService new] joinMessageEntourage:self.entourage message:message success:^(OTFeedItemJoiner *joiner) {
        NSLog(@"JOIN MESSAGE %@", message);
        if(success)
            success(joiner);
    } failure:^(NSError *error) {
        NSLog(@"JOIN MESSAGEerr: %@", error.description);
        if(failure)
            failure(error);
    }];
}

@end
