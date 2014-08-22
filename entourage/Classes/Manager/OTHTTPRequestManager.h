//
//  OTHTTPRequestManager.h
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

extern NSString *const kAPIPoiRoute;

@interface OTHTTPRequestManager : NSObject

/**************************************************************************************************/
#pragma mark - Singleton

+ (AFHTTPRequestOperationManager *)sharedInstance;

@end
