//
//  OTEntourageJoinerDelegate.m
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageJoinerDelegate.h"
#import "OTEntourageService.h"

@implementation OTEntourageJoinerDelegate

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

- (void)accept:(OTFeedItemJoiner *)joiner success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    [[OTEntourageService new] updateEntourageJoinRequestStatus:JOIN_ACCEPTED forUser:joiner.uID forEntourage:self.entourage.uid withSuccess:^() {
        NSLog(@"JOIN ACCEPT");
        if(success)
            success();
    } failure:^(NSError *error) {
        NSLog(@"JOIN ACCEPTerr: %@", error.description);
        if(failure)
            failure(error);
    }];
}

- (void)reject:(OTFeedItemJoiner *)joiner success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    [[OTEntourageService new] rejectEntourageJoinRequestForUser:joiner.uID forEntourage:self.entourage.uid withSuccess:^() {
        NSLog(@"JOIN REJECT");
        if(success)
            success();
    } failure:^(NSError *error) {
        NSLog(@"JOIN REJECTerr: %@", error.description);
        if(failure)
            failure(error);
    }];
}

@end
