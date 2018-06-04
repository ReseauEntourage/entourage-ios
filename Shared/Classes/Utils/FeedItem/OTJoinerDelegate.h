//
//  OTJoinerDelegate.h
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemJoiner.h"

@protocol OTJoinerDelegate <NSObject>

- (void)sendJoinMessage:(NSString *)message success:(void(^)(OTFeedItemJoiner *))success failure:(void (^)(NSError *)) failure;
- (void)accept:(OTFeedItemJoiner *)joiner success:(void(^)(void))success failure:(void (^)(NSError *)) failure;
- (void)reject:(OTFeedItemJoiner *)joiner success:(void(^)(void))success failure:(void (^)(NSError *)) failure;

@end
