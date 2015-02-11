//
//  OTHTTPRequestManager.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTHTTPRequestManager.h"

#import "OTUser.h"
#import "NSUserDefaults+OT.h"

static NSString *const kBaseAPIUrl = @"https://entourage-back.herokuapp.com/";
static NSString *const kBasePreprodAPIUrl = @"https://entourage-back-preprod.herokuapp.com/";

@implementation OTHTTPRequestManager

/**************************************************************************************************/
#pragma mark - Singleton

+ (AFHTTPRequestOperationManager *)sharedInstance {
	static AFHTTPRequestOperationManager *requestManager = nil;

	if (requestManager == nil) {
        NSString *url;
#ifdef DEBUG
        url = kBasePreprodAPIUrl;
#else
        url = kBaseAPIUrl;
#endif
		requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:url]];
		requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
		requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
	}

	return requestManager;
}

+ (NSDictionary*)commonParameters
{
    OTUser *user = [[NSUserDefaults standardUserDefaults] currentUser];

    return user ? @{ @"token" : user.token } : nil;
}


@end
