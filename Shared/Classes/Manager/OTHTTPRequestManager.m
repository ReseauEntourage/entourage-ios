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
#import "OTAppConfiguration.h"
#import "entourage-Swift.h"

@implementation OTHTTPRequestManager

/**************************************************************************************************/
#pragma mark - Singleton

+ (AFHTTPSessionManager *)sharedInstance {
    static OTRequestOperationManager *requestManager = nil;

    if (requestManager == nil) {

        NSString *apiBaseUrl = [[OTAppConfiguration sharedInstance].environmentConfiguration APIHostURL];
        requestManager = [[OTRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:apiBaseUrl]];

        requestManager.responseSerializer = [OTJSONResponseSerializer serializer];
        requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSString *apiKey = [[OTAppConfiguration sharedInstance].environmentConfiguration APIKey];
        NSString *versionB = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [requestManager.requestSerializer setValue:apiKey forHTTPHeaderField:@"X-API-KEY"];
        [requestManager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"X-Platform"];
        [requestManager.requestSerializer setValue:versionB forHTTPHeaderField:@"X-App-Version"];
    }
    return requestManager;
}

+ (NSDictionary*)commonParameters
{
    OTUser *user = [NSUserDefaults standardUserDefaults].currentUser;
    return user ? @{ @"token" : user.token } : nil;
}

@end
