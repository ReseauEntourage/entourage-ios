//
//  OTLogger.m
//  entourage
//
//  Created by sergiu buceac on 2/24/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTLogger.h"
#import "OTConsts.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "Flurry.h"
#import "Mixpanel/Mixpanel.h"

@implementation OTLogger

+ (void)logEvent:(NSString *)eventName {
    [Flurry logEvent:eventName];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:eventName];
}

+ (void)setupMixpanelWithUser: (OTUser *)user {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[user.sid stringValue]];
    [mixpanel.people set:@{@"$email": user.email != nil ? user.email : @""}];
    [mixpanel.people set:@{@"EntouragePartner": user.partner != nil ? user.partner.name : @""}];
    [mixpanel.people set:@{@"EntourageUserType": user.type}];
    NSString *language = [[NSLocale preferredLanguages] firstObject];
    [mixpanel.people set:@{@"EntourageLanguage": language}];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@DEVICE_TOKEN_KEY];
    if(token) {
        NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
        [mixpanel.people addPushDeviceToken:tokenData];
    }
}

@end
