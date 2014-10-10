//
//  OTHTTPRequestManager.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTHTTPRequestManager.h"

static NSString *const kBaseAPIUrl = @"https://entourage-back.herokuapp.com/";

@implementation OTHTTPRequestManager

/**************************************************************************************************/
#pragma mark - Singleton

+ (AFHTTPRequestOperationManager *)sharedInstance
{
    static AFHTTPRequestOperationManager *requestManager = nil;

    if (requestManager == nil)
    {
        requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseAPIUrl]];
        requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
        requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }

    return requestManager;
}

@end
