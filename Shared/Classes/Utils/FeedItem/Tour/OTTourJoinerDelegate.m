//
//  OTTourJoinerDelegate.m
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourJoinerDelegate.h"
#import "OTTourService.h"

@implementation OTTourJoinerDelegate

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

- (void)accept:(OTFeedItemJoiner *)joiner success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    [[OTTourService new] updateTourJoinRequestStatus:JOIN_ACCEPTED forUser:joiner.uID forTour:self.tour.uid withSuccess:^() {
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
    [[OTTourService new] rejectTourJoinRequestForUser:joiner.uID forTour:self.tour.uid withSuccess:^() {
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
