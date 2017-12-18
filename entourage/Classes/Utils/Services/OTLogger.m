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
#import "entourage-Swift.h"
#import "OTMixpanelService.h"

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
        NSDictionary *mixpanelDict =    @{@"$distinct_id": [user.sid stringValue],
                                                @"$token": [ConfigurationManager shared].MixpanelToken,
                                                @"$union": @{
                                                                @"$ios_devices" : @[token]
                                                            }
                                          };
    [[OTMixpanelService new] sendTokenDataWithDictionary:mixpanelDict success:nil failure:nil];
    }
}

@end
