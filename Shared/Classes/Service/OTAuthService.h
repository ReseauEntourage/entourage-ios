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

extern NSString *const kUserAuthenticationLevelOutside;
extern NSString *const kUserAuthenticationLevelAnonymous;
extern NSString *const kUserAuthenticationLevelAuthenticated;

@interface OTAuthService : NSObject

- (void)authWithPhone:(NSString *)phone
             password:(NSString *)password
              success:(void (^)(OTUser *user, BOOL firstLogin))success
              failure:(void (^)(NSError *error))failure;

- (void)getDetailsForUser:(NSString *)userUuid
                  success:(void (^)(OTUser *))success
                  failure:(void (^)(NSError *))failure;

- (void)deleteAccountForUser:(NSNumber *)userID
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *))failure;

+ (void)sendAppInfoWithPushToken:(NSString *)pushToken
             authorizationStatus:(NSString *)authorizationStatus
                         success:(void (^)(void))success
                         failure:(void (^)(NSError *))failure;

- (void)deletePushToken:(NSString *)pushToken forUser:(OTUser *)user;

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

- (void)updateUserInterests:(NSArray *)interests
                            success:(void (^)(OTUser *user))success
                            failure:(void (^)(NSError *error))failure;

- (void)subscribeToNewsletterWithEmail:(NSString *)email
                               success:(void (^)(BOOL))success
                               failure:(void (^)(NSError *))failure;

- (void)checkVersionWithSuccess:(void (^)(BOOL))success
                        failure:(void (^)(NSError *))failure;

+ (void)updateUserAddressWithPlaceId:(NSString *)placeId isSecondaryAddress:(BOOL) isSecondary
                          completion:(void (^)(NSError *))completion;

+ (void)updateUserAddressWithName:(NSString *)addressName
                        andLatitude:(NSNumber *) latitude
                        andLongitude:(NSNumber *) longitude
                        isSecondaryAddress:(BOOL) isSecondary
                        completion:(void (^)(NSError *))completion;

-(void)anonymousAuthWithSuccess:(void (^)(OTUser *))success
                        failure:(void (^)(NSError *))failure;

+ (void)prepareUploadPhotoWithSuccess:(void (^)(NSDictionary *user))success
                        failure:(void (^)(NSError *error))failure;

+(NSString *)authenticationLevelForUser:(OTUser *)user;
+(NSString *)currentUserAuthenticationLevel;

- (void)updateUserAssociationInfoWithAssociation:(OTAssociation *)association
                        success:(void (^)(Boolean isOk))success
                        failure:(void (^)(NSError *error))failure;
@end
