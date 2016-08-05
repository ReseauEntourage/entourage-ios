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
    [[OTEntourageService new] sendMessage:message
                              onEntourage:self.entourage
                                  success:^(OTTourMessage * tourMessage) {
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

@end
