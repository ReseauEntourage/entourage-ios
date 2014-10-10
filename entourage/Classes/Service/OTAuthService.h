//
//  OTUserServices.h
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//


@interface OTAuthService : NSObject

- (void)authWithEmail:(NSString *)email
              success:(void (^)(NSString *email))success
              failure:(void (^)(NSError *error))failure;
@end
