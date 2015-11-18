//
//  OTUserServices.h
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTUser.h"

@interface OTAuthService : NSObject

- (void)authWithPhone:(NSString *)phone
             password:(NSString *)password
             deviceId:(NSString *)deviceId
              success:(void (^)(OTUser *user))success
              failure:(void (^)(NSError *error))failure;

- (void)updateUserInformationWithEmail:(NSString *)email
                            andSmsCode:(NSString *)smsCode
                               success:(void (^)(NSString *user))success
                               failure:(void (^)(NSError *error))failure;

@end
