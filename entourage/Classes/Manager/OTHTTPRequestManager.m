//
//  OTHTTPRequestManager.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTHTTPRequestManager.h"
#import "OTJSONResponseSerializer.h"

#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTConsts.h"

@implementation OTHTTPRequestManager

/**************************************************************************************************/
#pragma mark - Singleton

+ (AFHTTPSessionManager *)sharedInstance {
	static OTRequestOperationManager *requestManager = nil;

	if (requestManager == nil) {
		requestManager = [[OTRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_API_URL]];
        
		requestManager.responseSerializer = [OTJSONResponseSerializer serializer];
		requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        //TODO api key should be changed after each release
        [requestManager.requestSerializer setValue:API_KEY forHTTPHeaderField:@"X-API-KEY"];
	}
	return requestManager;
}

+ (NSDictionary*)commonParameters
{
    OTUser *user =[NSUserDefaults standardUserDefaults].currentUser;
    return user ? @{ @"token" : user.token } : nil;
}

@end
