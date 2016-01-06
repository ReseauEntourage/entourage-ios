//
//  OTUserServices.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAuthService.h"

// Pods
#import <AFNetworking/AFNetworking.h>

// Manager
#import "OTHTTPRequestManager.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"

// Model
#import "OTUser.h"
#import "OTOrganization.h"

/**************************************************************************************************/
#pragma mark - Constants
NSString *const kAPIUserRoute = @"users";
NSString *const kAPIUpdateUserRoute = @"update_me";
NSString *const kAPIMe = @"me";
NSString *const kAPICode = @"code";

/**************************************************************************************************/
#pragma mark - Public methods

@implementation OTAuthService

- (void)authWithPhone:(NSString *)phone
             password:(NSString *)password
             deviceId:(NSString *)deviceId
              success:(void (^)(OTUser *))success
              failure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = @{ @"phone": phone, @"sms_code": password, @"device_type": @"ios", @"device_id": (deviceId == nil ? @"" : deviceId) };
    
    [[OTHTTPRequestManager sharedInstance]
     POST:@"login"
		parameters: parameters
     		success: ^(AFHTTPRequestOperation *operation, id responseObject)
            {
                NSDictionary *responseDict = responseObject;
                NSLog(@"Authentication service response : %@", responseDict);
                
                NSError *actualError = [self errorFromOperation:operation andError:nil];
                if (actualError) {
                    NSLog(@"errorMessage %@", actualError);
                    if (failure) {
                        failure(actualError);
                    }
                }
                else {
                    NSDictionary *responseUser = responseDict[@"user"];
                    OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
                    if (success) {
                        success(user);
                    }
                }
            }
            failure: ^(AFHTTPRequestOperation *operation, NSError *error)
            {
                    NSError *actualError = [self errorFromOperation:operation andError:error];
                    NSLog(@"Failed with error %@", actualError);
                if (failure) {
                    failure(actualError);
                }
            }];
}

- (void)regenerateSecretCode:(NSString *)phone
                     success:(void (^)(OTUser *))success
                     failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_regenerate_code", @""), kAPIUserRoute, kAPIMe, kAPICode];

    NSMutableDictionary *phoneDictionnary = [NSMutableDictionary new];
    phoneDictionnary[@"phone"] = phone;
    
    NSMutableDictionary *actionDictionnary = [NSMutableDictionary new];
    actionDictionnary[@"action"] = @"regenerate";
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"user"] = phoneDictionnary;
    parameters[@"code"] = actionDictionnary;
    
    [[OTHTTPRequestManager sharedInstance]
     PATCH:url
        parameters:parameters
            success:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                NSDictionary *responseDict = responseObject;
                
                NSError *actualError = [self errorFromOperation:operation andError:nil];
                if (actualError) {
                    NSLog(@"errorMessage %@", actualError);
                    if (failure) {
                        failure(actualError);
                    }
                }
                else {
                    NSDictionary *responseUser = responseDict[@"user"];
                    OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
                    if (success) {
                        success(user);
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
}


- (NSError *)errorFromOperation:(AFHTTPRequestOperation *)operation
                       andError:(NSError *)error {
	NSError *actualError = error;

	if ([operation responseString]) {
		// Convert to JSON object:
		NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding]
		                                                           options:0
		                                                             error:NULL];

		if ([jsonObject isKindOfClass:[NSDictionary class]] && [jsonObject objectForKey:@"error"]) {
			actualError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{ NSLocalizedDescriptionKey:[[jsonObject objectForKey:@"error"] objectForKey:@"message"] }];
		}
	}
	else {
		NSString *genericErrorMessage = @"Une erreur s'est produite. Vérifiez votre connexion réseau et réessayez.";
		actualError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{ NSLocalizedDescriptionKey:genericErrorMessage }];
	}
	return actualError;
}

- (void)updateUserInformationWithEmail:(NSString *)email
                            andSmsCode:(NSString *)smsCode
                               success:(void (^)(NSString *))success
                               failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:NSLocalizedString(@"url_update_user", @""), kAPIUserRoute, kAPIUpdateUserRoute, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[@"email"] = email;
    dictionary[@"sms_code"] = smsCode;
    
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[@"user"] = dictionary;
    
    [[OTHTTPRequestManager sharedInstance]
     PATCH:url
        parameters: parameters
            success: ^(AFHTTPRequestOperation *operation, id responseUser)
            {
                if (success) {
                    success([[responseUser objectForKey:@"user"] stringForKey:@"email"]);
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
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
     POST:@"newsletter_subscriptions"
        parameters:parameters
            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                NSDictionary *responseDict = responseObject;
                NSLog(@"Authentication service response : %@", responseDict);
                
                NSError *actualError = [self errorFromOperation:operation andError:nil];
                if (actualError) {
                    NSLog(@"errorMessage %@", actualError);
                    if (failure) {
                        failure(actualError);
                    }
                }
                else {
                    if (success) {
                        success(YES);
                    }
                }
            }
            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                NSError *actualError = [self errorFromOperation:operation andError:error];
                NSLog(@"Failed with error %@", actualError);
                if (failure) {
                    failure(actualError);
                }
            }];
}

@end
