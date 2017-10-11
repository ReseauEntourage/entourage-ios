//
//  OTLogger.m
//  entourage
//
//  Created by sergiu buceac on 2/24/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTLogger.h"
#import "Flurry.h"
#import "Mixpanel/Mixpanel.h"

@implementation OTLogger

+ (void)logEvent:(NSString *)eventName {
    [Flurry logEvent:eventName];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:eventName];
}

@end
