//
//  OTLogger.h
//  entourage
//
//  Created by sergiu buceac on 2/24/17.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTUser.h"

@interface OTLogger : NSObject

+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName withParameters:(nullable NSDictionary<NSString *, id> *)parameters;
+ (void)setupAnalyticsWithUser:(OTUser *)user;

@end
