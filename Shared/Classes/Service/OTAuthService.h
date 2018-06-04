//
//  OTUserServices.h
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTUser.h"

extern NSString *const kAPILogin;
extern NSString *const kAPIUserRoute;
extern NSString *const kKeychainPhone;
extern NSString *const kKeychainPassword;

@interface OTAuthService : NSObject

- (void)authWithPhone:(NSString *)phone
             password:(NSString *)password
             deviceId:(NSString *)deviceId
              success:(void (^)(OTUser *user))success
              failure:(void (^)(NSError *error))failure;

- (void)getDetailsForUser:(NSNumber *)userID
                  success:(void (^)(OTUser *))success
                  failure:(void (^)(NSError *))failure;

- (void)deleteAccountForUser:(NSNumber *)userID
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *))failure;

- (void)sendAppInfoWithSuccess:(void (^)(void))success
                       failure:(void (^)(NSError *))failure;

- (void)regenerateSecretCode:(NSString *)phone
                     success:(void (^)(OTUser *))success
                     failure:(void (^)(NSError *))failure;


- (void)updateUserInformationWithEmail:(NSString *)email
                            andSmsCode:(NSString *)smsCode
                               success:(void (^)(NSString *user))success
                               failure:(void (^)(NSError *error))failure;

- (void)updateUserInformationWithUser:(OTUser *)user
                              success:(void (^)(OTUser *user))success
                              failure:(void (^)(NSError *error))failure;

- (void)subscribeToNewsletterWithEmail:(NSString *)email
                               success:(void (^)(BOOL))success
                               failure:(void (^)(NSError *))failure;

- (void)checkVersionWithSuccess:(void (^)(BOOL))success
                        failure:(void (^)(NSError *))failure;

@end
