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

// Model
#import "OTUser.h"

@implementation OTAuthService

- (void)authWithPhone:(NSString *)phone
             password:(NSString *)password
             deviceId:(NSString *)deviceId
              success:(void (^)(OTUser *))success
              failure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = @{ @"phone": phone, @"sms_code": password, @"device_type": @"ios", @"device_id": deviceId };
    
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

@end
