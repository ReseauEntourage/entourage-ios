//
//  OTLogger.h
//  entourage
//
//  Created by sergiu buceac on 2/24/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTUser.h"

@interface OTLogger : NSObject

+ (void)logEvent:(NSString *)eventName;
+ (void)setupMixpanelWithUser:(OTUser *)user;

@end
