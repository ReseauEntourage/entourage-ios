//
//  OTVersionInfo.m
//  entourage
//
//  Created by sergiu buceac on 10/16/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTVersionInfo.h"

@implementation OTVersionInfo

+ (NSString *)currentVersion {
    return [NSString stringWithFormat:@"%@.%@", [self appVersion], [self build]];
}

+ (NSString *) appVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (NSString *) build {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

@end
