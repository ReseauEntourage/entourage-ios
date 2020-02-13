//
//  OTCrashlyticsHelper.m
//  entourage
//
//  Created by Grégoire Clermont on 07/02/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

#import "OTCrashlyticsHelper.h"

NSString *const OTNonFatalErrorDomain = @"OTNonFatalErrorDomain";

@implementation OTCrashlyticsHelper

+ (void)recordError:(NSString *)message userInfo:(NSDictionary *)userInfo {
    userInfo = [userInfo mutableCopy];
    [userInfo setValue:message forKey:NSLocalizedDescriptionKey];
    [CrashlyticsKit recordError:[NSError errorWithDomain:OTNonFatalErrorDomain
                                                    code:message.hash
                                                userInfo:userInfo]];
}

+ (void)recordError:(NSString *)message {
    [self recordError:message userInfo:@{}];
}

@end
