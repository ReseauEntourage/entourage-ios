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

- (void)stopWithSuccess:(void (^)())success {
    success();
}

- (void)deactivateWithSuccess:(void (^)(BOOL))success orFailure:(void (^)(NSError *))failure {
    self.entourage.status = FEEDITEM_STATUS_CLOSED;
    [[OTEntourageService new] closeEntourage:self.entourage
                                 withSuccess:^(OTEntourage *updatedEntourage) {
                                     NSLog(@"Closed entourage: %@", updatedEntourage.uid);
                                     success(NO);
                                 } failure:^(NSError *error) {
                                     NSLog(@"CLOSEerr %@", error.description);
                                     if(failure)
                                         failure(error);
                                 }];
}

- (void)quitWithSuccess:(void (^)())success {
    [[OTEntourageService new] quitEntourage:self.entourage
                          success:^() {
                              NSLog(@"Quited entourage: %@", self.entourage.uid);
                              success();
                          } failure:^(NSError *error) {
                              NSLog(@"QUITerr %@", error.description);
                          }];
}

@end
