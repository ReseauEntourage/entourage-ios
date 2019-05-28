//
//  OTAnalyticsObserver.m
//  entourage
//
//  Created by Grégoire Clermont on 24/05/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import "OTAnalyticsObserver.h"
#import "OTAuthService.h"
#import "OTUserUpdate.h"

@import FirebaseAnalytics;

@implementation OTAnalyticsObserver

+ (void)init {
    [OTAnalyticsObserver sharedInstance];
}

+ (OTAnalyticsObserver*)sharedInstance {
    static OTAnalyticsObserver* sharedInstance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    [self setupObservers];
    return self;
}

- (void)setupObservers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    [center addObserver:self
               selector:@selector(currentUserUpdated:)
                   name:[kNotificationCurrentUserUpdated copy]
                 object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observers

- (void)currentUserUpdated:(OTUserUpdate *)userUpdate {
    OTUser *previousUser = userUpdate.previousValue;
    OTUser *currentUser = userUpdate.currentValue;

    NSString *previousAuthenticationLevel = [OTAuthService authenticationLevelForUser:previousUser];
    NSString *currentAuthenticationLevel = [OTAuthService authenticationLevelForUser:currentUser];

    if ([currentAuthenticationLevel isEqualToString:previousAuthenticationLevel]) return;

    [FIRAnalytics setUserPropertyString:currentAuthenticationLevel forName:@"AuthenticationLevel"];
}

@end
