//
//  OTStateFactory.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"
#import "OTFeedItemJoiner.h"

@protocol OTStateTransitionDelegate <NSObject>

- (void)stopWithSuccess:(void (^)(void))success orFailure:(void (^)(NSError*))failure;
- (void)quitWithSuccess:(void (^)(void))success orFailure:(void (^)(NSError*))failure;
- (void)sendJoinRequest:(void (^)(OTFeedItemJoiner*))success orFailure:(void (^)(NSError*, BOOL))failure;
- (void)reopenEntourageWithSuccess:(void (^)(BOOL))success
                         orFailure:(void (^)(NSError *))failure;
- (void)closeWithOutcome:(BOOL)outcome
                andComment:(NSString *) comment
                 success:(void (^)(BOOL))success
               orFailure:(void (^)(NSError *))failure;
@end
