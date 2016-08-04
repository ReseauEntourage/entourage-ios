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

- (void)send:(NSString *)message withSuccess:(void (^)(OTTourMessage *))success orFailure:(void (^)(NSError *))failure {
    [[OTEntourageService new] sendMessage:message onEntourage:self.entourage success:^(OTTourMessage * tourMessage) {
            NSLog(@"CHAT %@", message);
            if(success)
                success(tourMessage);
        } failure:^(NSError *error) {
            NSLog(@"CHATerr: %@", error.description);
            if(failure)
                failure(error);
    }];
}

- (void)invitePhone:(NSString *)phone withSuccess:(void (^)())success orFailure:(void (^)(NSError *))failure {
    [[OTEntourageService new] inviteNumber:phone toEntourage:self.entourage success:^() {
        NSLog(@"INVITE BY PHONE %@", phone);
        if(success)
            success();
    } failure:^(NSError *error) {
        NSLog(@"ERROR INVITE BY PHONE %@", error.description);
        if(failure)
            failure(error);
    }];
}

- (void)sendJoinMessage:(NSString *)message success:(void (^)(OTTourJoiner *))success failure:(void (^)(NSError *))failure {
    [[OTEntourageService new] joinMessageEntourage:self.entourage message:message success:^(OTTourJoiner *joiner) {
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
