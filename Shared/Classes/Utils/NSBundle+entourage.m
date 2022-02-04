//
//  NSBundle+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 25/03/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "NSBundle+entourage.h"
#import "OTAppDelegate.h"

@implementation NSBundle (entourage)

+ (NSString *)currentVersion {
    NSDictionary *bundleInfoDictionary = [[NSBundle bundleForClass:[OTAppDelegate class]] infoDictionary];
    NSString *buildVersion = [bundleInfoDictionary objectForKey:@"CFBundleShortVersionString"];
    return buildVersion;
}

+ (NSString *)fullCurrentVersion {
    NSDictionary *bundleInfoDictionary = [[NSBundle bundleForClass:[OTAppDelegate class]] infoDictionary];
    NSString *buildVersion = [bundleInfoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [bundleInfoDictionary objectForKey:@"CFBundleVersion"];
    NSString *version = [NSString stringWithFormat:@"%@-%@", buildVersion, buildNumber];
    return version;
}

@end
