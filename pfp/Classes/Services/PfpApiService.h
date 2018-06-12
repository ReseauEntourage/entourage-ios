//
//  PfpApiService.h
//  pfp
//
//  Created by Smart Care on 06/06/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Parsing.h"
#import "OTHTTPRequestManager.h"
#import "ISO8601DateFormatter.h"

@interface PfpApiService : NSObject
+ (void)sendLastVisit:(NSDate *)date
        privateCircle:(OTUserMembershipListItem*)circle
           completion:(void(^)(NSError *))completion;
@end
