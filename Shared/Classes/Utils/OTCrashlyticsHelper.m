//
//  OTCrashlyticsHelper.m
//  entourage
//
//  Created by Grégoire Clermont on 07/02/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

#import "OTCrashlyticsHelper.h"

NSString *const OTNonFatalErrorDomain = @"OTNonFatalErrorDomain";

@implementation OTCrashlyticsHelper

+ (void)recordError:(NSString *)message {
    [[FIRCrashlytics crashlytics] log:message];
}

@end
