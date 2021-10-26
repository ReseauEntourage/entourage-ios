//
//  OTLogger.m
//  entourage
//
//  Created by sergiu buceac on 2/24/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTLogger.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTMixpanelService.h"
#import "OTAppConfiguration.h"
#import "entourage-Swift.h"

@import Firebase;

@implementation OTLogger

+ (void)logEvent:(NSString *)eventName {
    [self logEvent:eventName withParameters:nil];
}

+ (void)logEvent:(NSString *)eventName withParameters:(nullable NSDictionary<NSString *, id> *)parameters {
    [FIRAnalytics logEventWithName:eventName parameters:parameters];
}

+ (void)setupAnalyticsWithUser: (OTUser *)user {
    [FIRAnalytics setUserID:[user.sid stringValue]];
    [FIRAnalytics setUserPropertyString:(user.partner != nil ? user.partner.name : @"") forName:@"EntouragePartner"];
    if (user.type) {
        [FIRAnalytics setUserPropertyString:user.type forName:@"EntourageUserType"];
    }
  
    NSString *language = [[NSLocale preferredLanguages] firstObject];
    [FIRAnalytics setUserPropertyString:language forName:@"Language"];
}

@end
