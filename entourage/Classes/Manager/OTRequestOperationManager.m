//
//  OTRequestOperationManager.m
//  entourage
//
//  Created by Nicolas Telera on 27/01/2016.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"
#import "OTConsts.h"

// Pods
#import "SimpleKeychain.h"

// Manager
#import "OTRequestOperationManager.h"

// Service
#import "OTAuthService.h"

@implementation OTRequestOperationManager

- (void)GETWithUrl:(NSString *)url
     andParameters:(NSDictionary *)parameters
        andSuccess:(void (^)(id responseObject))success
        andFailure:(void (^)(NSError *error))failure
{
    [self GET:url parameters:parameters
    success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
    {
        if (success) {
            success(responseObject);
        }
    }
    failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error)
    {
        if ([operation.response statusCode] == 401) {
            [self askForNewTokenWithMethod:@"GET" andUrl:url andParameters:parameters andSuccess:success andFailure:failure];
        }
        else {
            NSError *actualError = [self errorFromOperation:operation andError:error];
            if (failure) {
                failure(actualError);
            }
        }
    }];
}

- (void)POSTWithUrl:(NSString *)url
      andParameters:(NSDictionary *)parameters
         andSuccess:(void (^)(id responseObject))success
         andFailure:(void (^)(NSError *error))failure
{
    [self   POST:url
            parameters:parameters
            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                if (success) {
                    success(responseObject);
                }
            }
            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                if ([operation.response statusCode] == 401) {
                    if (![url isEqualToString:kAPILogin]) {
                        [self askForNewTokenWithMethod:@"POST" andUrl:url andParameters:parameters andSuccess:success andFailure:failure];
                    }
                    else {
                        NSError *actualError = [self errorFromOperation:operation andError:error];
                        if (failure) {
                            failure(actualError);
                        }
                    }
                    
                }
                else {
                    NSError *actualError = [self errorFromOperation:operation andError:error];
                    if (failure) {
                        failure(actualError);
                    }
                }
    }];
}

- (void)PUTWithUrl:(NSString *)url
     andParameters:(NSDictionary *)parameters
        andSuccess:(void (^)(id responseObject))success
        andFailure:(void (^)(NSError *error))failure
{
    [self PUT:url
   parameters:parameters
      success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
        {
            if (success) {
                success(responseObject);
            }
        }
      failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error)
        {
            if ([operation.response statusCode] == 401) {
                [self askForNewTokenWithMethod:@"PUT" andUrl:url andParameters:parameters andSuccess:success andFailure:failure];
            }
            else {
                NSError *actualError = [self errorFromOperation:operation andError:error];
                if (failure) {
                    failure(actualError);
                }
            }
    }];
}

- (void)PATCHWithUrl:(NSString *)url
       andParameters:(NSDictionary *)parameters
          andSuccess:(void (^)(id responseObject))success
          andFailure:(void (^)(NSError *error))failure
{
    [self PATCH:url parameters:parameters
    success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
    {
        if (success) {
            success(responseObject);
        }
    }
    failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error)
    {
        if ([operation.response statusCode] == 401) {
            [self askForNewTokenWithMethod:@"PATCH" andUrl:url andParameters:parameters andSuccess:success andFailure:failure];
        }
        else {
            NSError *actualError = [self errorFromOperation:operation andError:error];
            if (failure) {
                failure(actualError);
            }
        }
    }];
}

- (void)DELETEWithUrl:(NSString *)url
        andParameters:(NSDictionary *)parameters
           andSuccess:(void (^)(id responseObject))success
           andFailure:(void (^)(NSError *error))failure
{
    [self DELETE:url
      parameters:parameters
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject)
         {
             if (success) {
                 success(responseObject);
             }
         }
        failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error)
         {
             if ([operation.response statusCode] == 401) {
                 [self askForNewTokenWithMethod:@"DELETE" andUrl:url andParameters:parameters andSuccess:success andFailure:failure];
             }
             else {
                 NSError *actualError = [self errorFromOperation:operation andError:error];
                 if (failure) {
                     failure(actualError);
                 }
             }
     }];

}


- (void)askForNewTokenWithMethod:(NSString *)method
                          andUrl:(NSString *)url
                   andParameters:(NSDictionary *)parameters
                      andSuccess:(void (^)(id responseObject))success
                      andFailure:(void (^)(NSError *error))failure
{
    NSString *phone = [[A0SimpleKeychain keychain] stringForKey:kKeychainPhone];
    NSString *password = [[A0SimpleKeychain keychain] stringForKey:kKeychainPassword];
    NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:@DEVICE_TOKEN_KEY];
    
    if (phone != nil && password != nil) {
        NSDictionary *params = @{ @"phone": phone,
                                  @"sms_code": password,
                                  @"device_type": @"ios",
                                  @"device_id": (deviceId == nil ? @"" : deviceId) };
        [self POSTWithUrl:kAPILogin
            andParameters:params
               andSuccess:^(id responseObject) {
                   if ([method isEqualToString:@"GET"])
                       [self GETWithUrl:url andParameters:parameters andSuccess:success andFailure:failure];
                   else if ([method isEqualToString:@"POST"])
                       [self POSTWithUrl:url andParameters:parameters andSuccess:success andFailure:failure];
                   else if ([method isEqualToString:@"PUT"])
                       [self PUTWithUrl:url andParameters:parameters andSuccess:success andFailure:failure];
                   else if ([method isEqualToString:@"PATCH"])
                       [self PATCHWithUrl:url andParameters:parameters andSuccess:success andFailure:failure];
                   else if ([method isEqualToString:@"DELETE"])
                       [self DELETEWithUrl:url andParameters:parameters andSuccess:success andFailure:failure];
               } andFailure:^(NSError *error) {
                   if (failure)
                       failure(error);
                   [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailureNotification object:self];
               }];
    }
}

- (NSError *)errorFromOperation:(AFHTTPRequestOperation *)operation andError:(NSError *)error {
    NSError *actualError = error;
    @synchronized (actualError) {
        if ([operation responseString]) {
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[[operation responseString] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
            if ([jsonObject isKindOfClass:[NSDictionary class]] && [jsonObject objectForKey:@"error"]) {
                NSString *errorString = @"";
                id errorValue = [jsonObject objectForKey:@"error"];
                if ([errorValue isKindOfClass:[NSDictionary class]] && [errorValue objectForKey:@"message"])
                    errorString = [errorValue objectForKey:@"message"];
                else
                    errorString = errorValue;
                actualError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{ NSLocalizedDescriptionKey:errorString }];
            }
        }
        else {
            NSString *genericErrorMessage = OTLocalizedString(@"generic_error");
            actualError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{ NSLocalizedDescriptionKey:genericErrorMessage }];
        }
        return actualError;
    }
}

@end
