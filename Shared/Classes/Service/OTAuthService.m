//
//  OTUserServices.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 Entourage. All rights reserved.
//

#import "OTAuthService.h"

// Pods
#import <AFNetworking/AFNetworking.h>
#import <SimpleKeychain/SimpleKeychain.h>

// Manager
#import "OTHTTPRequestManager.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"
#import "NSBundle+entourage.h"

// Model
#import "OTUser.h"
#import "OTOrganization.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"
#import "OTAddress.h"
#import "OTCrashlyticsHelper.h"

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kAPIApps = @"applications";

NSString *const kAPILogin = @"login";
NSString *const kAPIAnonymousLogin = @"anonymous_users";
NSString *const kAPIUserRoute = @"users";
NSString *const kAPIUpdateUserRoute = @"update_me";
NSString *const kAPIMe = @"me";
NSString *const kAPICode = @"code";
NSString *const kKeychainPhone = @"entourage_user_phone";
NSString *const kKeychainPassword = @"entourage_user_password";

NSString *const kUserAuthenticationLevelOutside = @"outside";
NSString *const kUserAuthenticationLevelAnonymous = @"anonymous";
NSString *const kUserAuthenticationLevelAuthenticated = @"authenticated";

/**************************************************************************************************/
#pragma mark - Public methods

@implementation OTAuthService

- (void)authWithPhone:(NSString *)phone
             password:(NSString *)password
              success:(void (^)(OTUser *, BOOL))success
              failure:(void (^)(NSError *))failure
{
    if (phone == nil || password == nil) {
        if (failure) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: OTLocalizedString(@"generic_error")};
            failure([NSError errorWithDomain:@"entourageError" code:-1 userInfo:userInfo]);
        }
        return;
    }
    NSDictionary *parameters = @{@"user": @{@"phone": phone, @"sms_code": password}};
    OTRequestOperationManager *requestManager = [OTHTTPRequestManager sharedInstance];
    [requestManager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSLog(@"Login with user %@", parameters);
    //NSLog(@"Login header: %@"OTApiErrorDomain, requestManager.requestSerializer.HTTPRequestHeaders);
    [requestManager
         POSTWithUrl:kAPILogin
         andParameters:parameters
         andSuccess:^(id responseObject) {
             NSDictionary *responseDict = responseObject;
             NSLog(@"Authentication service response : %@", responseDict);
             NSDictionary *responseUser = responseDict[@"user"];
             OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
             BOOL firstLogin = [responseDict boolForKey:@"first_sign_in"];
             [[A0SimpleKeychain keychain] setString:phone forKey:kKeychainPhone];
             [[A0SimpleKeychain keychain] setString:password forKey:kKeychainPassword];
             
             if (success) {
                 success(user, firstLogin);
             }
         }
         andFailure:^(NSError *error)
         {
             [OTCrashlyticsHelper recordError:error];
             NSLog(@"Failed with error %@", error);
             if (failure) {
                 failure(error);
             }
     }];
}

- (void)deleteAccountForUser:(NSNumber *)userID
                     success:(void (^)(void))success
                     failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_DELETE_ACCOUNT, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
         DELETEWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject) {
             if (success) {
                 success();
             }
         }
         andFailure:^(NSError *error)
         {
             NSLog(@"Failed with error %@", error);
             if (failure) {
                 failure(error);
             }
         }];

}

- (void)getDetailsForUser:(NSString *)userUuid
                            success:(void (^)(OTUser *))success
                            failure:(void (^)(NSError *))failure
{

    NSString *url = [NSString stringWithFormat:API_URL_USER_DETAILS, userUuid, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
         GETWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject) {
             NSDictionary *responseDict = responseObject;
             NSDictionary *responseUser = responseDict[@"user"];
             OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
             
             // FIXME: this is a hack to work around the fact that anonymous users' attributes
             // are not actually persisted server side.
             OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
             if ([user.uuid isEqualToString:currentUser.uuid] &&
                 [responseUser[@"placeholders"] isKindOfClass:[NSArray class]]) {
                 
                 if ([responseUser[@"placeholders"] containsObject:@"firebase_properties"]) {
                     user.firebaseProperties = currentUser.firebaseProperties;
                 }
                 if ([responseUser[@"placeholders"] containsObject:@"address"]) {
                     user.addressPrimary = currentUser.addressPrimary;
                 }
             }

             if (success) {
                 success(user);
             }
         }
         andFailure:^(NSError *error)
         {
             NSLog(@"Failed with error %@", error);
             if (failure) {
                 failure(error);
             }
         }];
}

+ (void)sendAppInfoWithPushToken:(NSString *)pushToken
             authorizationStatus:(NSString *)authorizationStatus
                         success:(void (^)(void))success
                         failure:(void (^)(NSError *))failure
{
    if (!pushToken)
        return;
    
    NSString *deviceiOS = [NSString stringWithFormat:@"iOS %@",[[NSProcessInfo processInfo] operatingSystemVersionString]];
    
    NSString *version = [NSBundle currentVersion];
    NSDictionary *parameters =  @{@"application": @{@"push_token": pushToken, @"device_os" : deviceiOS, @"version" : version, @"notifications_permissions" : authorizationStatus}};
    
    
    NSString *url = [NSString stringWithFormat:@"%@?token=%@", kAPIApps, TOKEN];
    NSLog(@"Applications: %@\n%@", url, parameters);
    
    [[OTHTTPRequestManager sharedInstance]
     PUTWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject) {
         if (success) {
             success();
         }
     }
     andFailure:^(NSError *error)
     {
         NSLog(@"Failed with error %@", error);
         if (failure) {
             failure(error);
         }
     }];
}

- (void)deletePushToken:(NSString *)pushToken forUser:(OTUser *)user {
    if (pushToken == nil) {
        return;
    }
    NSDictionary *parameters =  @{@"application": @{@"push_token": pushToken}};
    NSString *url = [NSString stringWithFormat:@"%@?token=%@", kAPIApps, user.token];

    [[OTHTTPRequestManager sharedInstance]
        DELETEWithUrl:url
        andParameters:parameters
        andSuccess:nil
        andFailure:^(NSError *error) {
            NSLog(@"Failed with error %@", error);
        }];
}

- (void)regenerateSecretCode:(NSString *)phone
                     success:(void (^)(OTUser *))success
                     failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_REGENERATE_CODE, kAPIUserRoute, kAPIMe, kAPICode];
    
    NSMutableDictionary *phoneDictionnary = [NSMutableDictionary new];
    phoneDictionnary[@"phone"] = phone;
    
    NSMutableDictionary *actionDictionnary = [NSMutableDictionary new];
    actionDictionnary[@"action"] = @"regenerate";
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"user"] = phoneDictionnary;
    parameters[@"code"] = actionDictionnary;
    
    [[OTHTTPRequestManager sharedInstance]
     PATCHWithUrl:url andParameters:parameters
     andSuccess:^(id responseObject)
     {
         NSDictionary *responseDict = responseObject;
         NSDictionary *responseUser = responseDict[@"user"];
         OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
         if (success) {
             success(user);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

- (void)updateUserInformationWithEmail:(NSString *)email
                            andSmsCode:(NSString *)smsCode
                               success:(void (^)(NSString *))success
                               failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_UPDATE_USER, kAPIUserRoute, kAPIMe, TOKEN];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[@"email"] = email;
    dictionary[@"sms_code"] = smsCode;
    
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[@"user"] = dictionary;
    
    [[OTHTTPRequestManager sharedInstance]
     PATCHWithUrl:url andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success) {
             NSDictionary *responseDict = responseObject;
             NSDictionary *responseUser = responseDict[@"user"];
             success([responseUser stringForKey:@"email"]);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

+ (void)updateUserAddressWithPlaceId:(NSString *)placeId isSecondaryAddress:(BOOL) isSecondary
                               completion:(void (^)(NSError *))completion
{
    NSString *_url = isSecondary ? API_URL_UPDATE_ADDRESS_SECONDARY : API_URL_UPDATE_ADDRESS_PRIMARY;
    NSString *url = [NSString stringWithFormat:_url, TOKEN];

    NSMutableDictionary *address = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    address[kWSKeyGooglePlaceId] = placeId;
    parameters[@"address"] = address;
    
    [[OTHTTPRequestManager sharedInstance] POSTWithUrl:url
                                         andParameters:parameters
                                            andSuccess:^(id responseObject) {
                                                NSDictionary *responseDict = responseObject;
                                                NSLog(@"Authentication service response : %@", responseDict);
                                                NSDictionary * dictUser = responseDict[@"user"];
                                                OTUser *newUser = [[OTUser alloc] initWithDictionary:dictUser];
                                                
                                                if (newUser.uuid != nil && newUser.uuid.length > 0) {
                                                    OTUser *user = [NSUserDefaults standardUserDefaults].currentUser;
                                                    newUser.phone = user.phone;
                                                                               
                                                    [[NSUserDefaults standardUserDefaults] setCurrentUser:newUser];
                                                }
        
                                                if (completion) {
                                                    completion(nil);
                                                }
                                            }
                                            andFailure:^(NSError *error) {
                                                if (completion) {
                                                    completion(error);
                                                }
                                            }
     ];
}

+ (void)updateUserAddressWithName:(NSString *)addressName andLatitude:(NSNumber *) latitude
                     andLongitude:(NSNumber *) longitude isSecondaryAddress:(BOOL) isSecondary completion:(void (^)(NSError *))completion {
    
    NSString *_url = isSecondary ? API_URL_UPDATE_ADDRESS_SECONDARY : API_URL_UPDATE_ADDRESS_PRIMARY;
    NSString *url = [NSString stringWithFormat:_url, TOKEN];

    NSMutableDictionary *address = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    address[kWSKeyPlaceName] = addressName;
    address[kWSKeyPlaceLatitude] = latitude;
    address[kWSKeyPlaceLongitude] = longitude;
    parameters[@"address"] = address;
    
    [[OTHTTPRequestManager sharedInstance] POSTWithUrl:url
                                         andParameters:parameters
                                            andSuccess:^(id responseObject) {
                                                NSDictionary *responseDict = responseObject;
                                                NSLog(@"Authentication service response : %@", responseDict);
                                                NSDictionary * dictUser = responseDict[@"user"];
                                                OTUser *newUser = [[OTUser alloc] initWithDictionary:dictUser];
                                                 
                                                if (newUser != nil) {
                                                    OTUser *user = [NSUserDefaults standardUserDefaults].currentUser;
                                                    newUser.phone = user.phone;
                                
                                                    [[NSUserDefaults standardUserDefaults] setCurrentUser:newUser];
                                                }
        
                                                if (completion) {
                                                    completion(nil);
                                                }
                                            }
                                            andFailure:^(NSError *error) {
                                                if (completion) {
                                                    completion(error);
                                                }
                                            }
     ];
}

+(void)deleteUserSecondaryAddressWithCompletion:(void (^)(NSError *))completion {
    NSString *_url = API_URL_UPDATE_ADDRESS_SECONDARY;
    NSString *url = [NSString stringWithFormat:_url, TOKEN];
    [[OTHTTPRequestManager sharedInstance] DELETEWithUrl:url andParameters:nil andSuccess:^(id responseObject) {
        
        OTUser *user = [NSUserDefaults standardUserDefaults].currentUser;
        user.addressSecondary = nil;
        [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
        
        if (completion) {
            completion(nil);
        }
        
    } andFailure:^(NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (void)updateUserInformationWithUser:(OTUser *)user
                              success:(void (^)(OTUser *user))success
                              failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_UPDATE_USER, kAPIUserRoute, kAPIMe, TOKEN];
    
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[@"user"] = [user dictionaryForWebservice];
    
    [[OTHTTPRequestManager sharedInstance]
            PATCHWithUrl:url
            andParameters:parameters
            andSuccess:^(id responseObject)
         {
             if (success) {
                 // CHECK THIS
                 NSDictionary *responseDict = responseObject;
                 NSDictionary *responseUser = responseDict[@"user"];
                 OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
                 success(user);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure) {
                 failure(error);
             }
         }];
}

- (void)updateUserInterests:(NSArray *)interests
                              success:(void (^)(OTUser *user))success
                              failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_UPDATE_USER, kAPIUserRoute, kAPIMe, TOKEN];
    
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    NSMutableDictionary *dictInterests = [NSMutableDictionary new];
    dictInterests[@"interests"] = interests;
    parameters[@"user"] = dictInterests;
    
    NSLog(@"Interests dict : %@",parameters);
    
    [[OTHTTPRequestManager sharedInstance]
            PATCHWithUrl:url
            andParameters:parameters
            andSuccess:^(id responseObject)
         {
             if (success) {
                 // CHECK THIS
                 NSDictionary *responseDict = responseObject;
                 NSDictionary *responseUser = responseDict[@"user"];
                 OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
                 success(user);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure) {
                 failure(error);
             }
         }];
}

- (void)subscribeToNewsletterWithEmail:(NSString *)email
                               success:(void (^)(BOOL))success
                               failure:(void (^)(NSError *))failure
{
    NSDictionary *dict = @{ @"email": email, @"active": @"true" };
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"newsletter_subscription"] = dict;
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:@"newsletter_subscriptions" andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success) {
             success(YES);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

- (void)checkVersionWithSuccess:(void (^)(BOOL))success
                        failure:(void (^)(NSError *))failure
{
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:@"check"
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         NSString *status = [responseObject stringForKey:@"status"];
         if (success) {
             if ([status isEqualToString:@"ok"]) {
                 success(YES);
             } else {
                 success(NO);
             }
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

-(void)anonymousAuthWithSuccess:(void (^)(OTUser *))success failure:(void (^)(NSError *))failure
{
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:kAPIAnonymousLogin
     andParameters:nil
     andSuccess:^(id responseObject) {
         NSDictionary *responseDict = responseObject;
         NSLog(@"Anonymous auth response : %@", responseDict);
         NSDictionary *responseUser = responseDict[@"user"];
         OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];

         if (success) {
             success(user);
         }
     }
     andFailure:^(NSError *error)
     {
        [OTCrashlyticsHelper recordError:error];
         NSLog(@"Failed with error %@", error);
         if (failure) {
             failure(error);
         }
     }];
}

- (void)updateUserAssociationInfoWithAssociation:(OTAssociation *)association
                              success:(void (^)(Boolean isOk))success
                              failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_USER_UPDATE_ASSOCIATION_INFO, TOKEN];
    
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    if (association.aid != nil && association.aid.intValue > 0) {
        parameters[@"partner_id"] = association.aid;
    }
    
    if (association.isCreation) {
        parameters[@"new_partner_name"] = association.name;
    }
    
    parameters[@"postal_code"] = association.postal_code;
    parameters[@"partner_role_title"] = association.userRoleTitle;
    
    NSLog(@"Parameters post info assos %@",parameters);
    
    [[OTHTTPRequestManager sharedInstance]
            POSTWithUrl:url
            andParameters:parameters
            andSuccess:^(id responseObject)
         {
             if (success) {
                 success(YES);
             }
             else {
                 success(NO);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure) {
                 failure(error);
             }
         }];
}

+ (void)prepareUploadPhotoWithSuccess:(void (^)(NSDictionary *infos))success
                   failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"content_type"] = @"image/jpeg";
    
    NSString *url = [NSString stringWithFormat:@"%@?token=%@", API_URL_USER_PREPARE_AVATAR_UPLOAD, TOKEN];
    NSLog(@"Applications: %@\n%@", url, parameters);
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success) {
             success(responseObject);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

+(NSString *)authenticationLevelForUser:(OTUser *)user {
    if (!user) {
        return kUserAuthenticationLevelOutside;
    }
    else if (user.isAnonymous) {
        return kUserAuthenticationLevelAnonymous;
    }
    else {
        return kUserAuthenticationLevelAuthenticated;
    }
}

+(NSString *)currentUserAuthenticationLevel {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    return [self authenticationLevelForUser:currentUser];
}
@end
