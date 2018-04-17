//
//  OTHTTPRequestManager.h
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTRequestOperationManager.h"

@interface OTHTTPRequestManager : NSObject

/**************************************************************************************************/
#pragma mark - Singleton

+ (OTRequestOperationManager *)sharedInstance;
+ (NSDictionary*)commonParameters;

@end
