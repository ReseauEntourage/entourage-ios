//
//  OTMessagingDelegate.h
//  entourage
//
//  Created by sergiu buceac on 7/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTTourMessage.h"

@protocol OTMessagingDelegate <NSObject>

- (void)send:(NSString *)message withSuccess:(void (^)(OTTourMessage *))success orFailure:(void (^)(NSError *))failure;
- (void)invitePhone:(NSString *)phone withSuccess:(void (^)())success orFailure:(void (^)(NSError *))failure;
- (void)sendJoinMessage:(NSString *)message success:(void(^)(OTTourJoiner *))success failure:(void (^)(NSError *)) failure;

@end
