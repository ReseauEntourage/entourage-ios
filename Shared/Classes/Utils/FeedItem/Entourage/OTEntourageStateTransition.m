//
//  OTEntourageStateFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageStateTransition.h"
#import "OTEntourage.h"
#import "OTUser.h"
#import "OTEntourageService.h"

@implementation OTEntourageStateTransition

- (void)stopWithSuccess:(void (^)())success orFailure:(void (^)(NSError *))failure {
    success();
}

- (void)closeWithSuccess:(void (^)(BOOL))success orFailure:(void (^)(NSError *))failure {
    NSString *oldState = self.entourage.status;
    self.entourage.status = FEEDITEM_STATUS_CLOSED;
    [[OTEntourageService new] closeEntourage:self.entourage
                                 withSuccess:^(OTEntourage *updatedEntourage) {
                                     NSLog(@"Closed entourage: %@", updatedEntourage.uid);
                                     success(NO);
                                 } failure:^(NSError *error) {
                                     NSLog(@"CLOSEerr %@", error.description);
                                     self.entourage.status = oldState;
                                     if(failure)
                                         failure(error);
                                 }];
}

- (void)quitWithSuccess:(void (^)())success orFailure:(void (^)(NSError *))failure {
    NSString *oldJoinState = self.entourage.joinStatus;
    self.entourage.joinStatus = JOIN_NOT_REQUESTED;
    [[OTEntourageService new] quitEntourage:self.entourage
                          success:^() {
                              NSLog(@"Quited entourage: %@", self.entourage.uid);
                              success();
                          } failure:^(NSError *error) {
                              NSLog(@"QUITerr %@", error.description);
                              self.entourage.joinStatus = oldJoinState;
                              if(failure)
                                  failure(error);
                          }];
}

- (void)sendJoinRequest:(void (^)(OTFeedItemJoiner *))success orFailure:(void (^)(NSError *, BOOL))failure {
    [OTLogger logEvent:@"OpenEnterInContact"];
    NSString *oldJoinState = self.entourage.joinStatus;
    self.entourage.joinStatus = JOIN_PENDING;
    [[OTEntourageService new] joinEntourage:self.entourage
        success:^(OTFeedItemJoiner *joiner) {
            NSLog(@"Sent entourage join request: %@", self.entourage.uid);
            success(joiner);
        } failure:^(NSError *error) {
            NSLog(@"Send entourage join request error: %@", error.description);
            self.entourage.joinStatus = oldJoinState;
            failure(error, NO);
        }];
}

@end