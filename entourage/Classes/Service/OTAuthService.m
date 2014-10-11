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

- (void)authWithEmail:(NSString *)email
              success:(void (^)(OTUser *user))success
              failure:(void (^)(NSError *error))failure {
	NSDictionary *parameters = @{ @"email": email };

	[[OTHTTPRequestManager sharedInstance]
	 POST:@"users/validation"
	    parameters:parameters
	       success: ^(AFHTTPRequestOperation *operation, id responseObject)
	{
	    NSDictionary *responseDict = responseObject;
	    NSLog(@"Authentication service response : %@", responseDict);

	    NSString *errorMessage = responseDict[@"error"][@"message"];
	    NSLog(@"errorMessage %@", errorMessage);

	    if (errorMessage) {
	        NSError *error = [NSError errorWithDomain:@"Entourage" code:-1 userInfo:@{ NSLocalizedDescriptionKey:errorMessage }];
	        if (failure) {
	            failure(error);
			}
		}
	    else {
	        OTUser *user = [OTUser new];
	        NSDictionary *responseUser = responseDict[@"user"];
	        user = [user initWithDictionary:responseUser];
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

		if ([jsonObject isKindOfClass:[NSDictionary class]] && [jsonObject objectForKey:@"code"]) {
			actualError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{ NSLocalizedDescriptionKey:[jsonObject objectForKey:@"label"] }];
		}
	}
	else {
		NSString *genericErrorMessage = @"Une erreur s'est produite. Vérifiez votre connexion réseau et réessayez.";
		actualError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{ NSLocalizedDescriptionKey:genericErrorMessage }];
	}
	return actualError;
}

@end
