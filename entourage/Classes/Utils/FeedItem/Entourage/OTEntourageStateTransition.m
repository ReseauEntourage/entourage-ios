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

- (void)closeWithSuccess:(void (^)())success {
    self.entourage.status = FEEDITEM_STATUS_CLOSED;
    [[OTEntourageService new] closeEntourage:self.entourage
                       withSuccess:^(OTEntourage *updatedEntourage) {
                           NSLog(@"Closed entourage: %@", updatedEntourage.uid);
                           success();
                       } failure:^(NSError *error) {
                           NSLog(@"CLOSEerr %@", error.description);
                       }];
}

- (void)freezeWithSuccess:(void (^)())success {
    success();
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
