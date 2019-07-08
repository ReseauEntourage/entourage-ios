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
#import <Mixpanel/Mixpanel.h>
#import "OTMixpanelService.h"
#import "OTAppConfiguration.h"
#import "entourage-Swift.h"

@import Firebase;

@implementation OTLogger

+ (void)logEvent:(NSString *)eventName {
    [self logEvent:eventName withParameters:nil];
}

+ (void)logEvent:(NSString *)eventName withParameters:(nullable NSDictionary<NSString *, id> *)parameters {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:eventName];
    [FIRAnalytics logEventWithName:eventName parameters:parameters];
}

+ (void)setupMixpanelWithUser: (OTUser *)user {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[user.sid stringValue]];
    [FIRAnalytics setUserID:[user.sid stringValue]];
    [mixpanel.people set:@{@"$email": user.email != nil ? user.email : @""}];
    [FIRAnalytics setUserPropertyString:(user.email != nil ? user.email : @"") forName:@"$email"];
    [mixpanel.people set:@{@"EntouragePartner": user.partner != nil ? user.partner.name : @""}];
    [FIRAnalytics setUserPropertyString:(user.partner != nil ? user.partner.name : @"") forName:@"EntouragePartner"];
    if (user.type) {
        [mixpanel.people set:@{@"EntourageUserType": user.type}];
        [FIRAnalytics setUserPropertyString:user.type forName:@"EntourageUserType"];
    }
  
    NSString *language = [[NSLocale preferredLanguages] firstObject];
    [mixpanel.people set:@{@"Language": language}];
    [FIRAnalytics setUserPropertyString:language forName:@"Language"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@DEVICE_TOKEN_KEY];
    NSString *mixpanelToken = [OTAppConfiguration sharedInstance].environmentConfiguration.MixpanelToken;
    
    if(token) {
        NSDictionary *mixpanelDict =    @{@"$distinct_id": [user.sid stringValue],
                                                @"$token": mixpanelToken,
                                                @"$union": @{
                                                                @"$ios_devices" : @[token]
                                                            }
                                          };
        [[OTMixpanelService new] sendTokenDataWithDictionary:mixpanelDict success:nil failure:nil];
    }
}

@end
