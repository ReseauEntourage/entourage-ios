//
//  OTEntourageStateFactory.m
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageStateFactory.h"
#import "OTEntourage.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTEntourageService.h"

@implementation OTEntourageStateFactory

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

- (FeedItemState)getActionableState {
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if ([currentUser.sid intValue] == [self.entourage.author.uID intValue]) {
        NSLog(@"status>>> %@", self.entourage.status);
        if ([self.entourage.status isEqualToString:ENTOURAGE_STATUS_OPEN])
            return FeedItemStateClosed;
    } else {
        return FeedItemStateQuit;
    }
    return FeedItemStateNone;
}

- (BOOL)canChangeState {
    return ![self.entourage.status isEqualToString:FEEDITEM_STATUS_CLOSED];
}

@end
