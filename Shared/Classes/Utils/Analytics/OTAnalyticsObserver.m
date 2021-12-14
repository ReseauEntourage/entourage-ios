//
//  OTAnalyticsObserver.m
//  entourage
//
//  Created by Grégoire Clermont on 24/05/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import "OTAnalyticsObserver.h"
#import "OTAuthService.h"

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

- (void)currentUserUpdated:(NSNotification *)userUpdate {
    OTUser *previousUser;
    OTUser *currentUser;
    
    if (userUpdate.userInfo[@"previousValue"] == [NSNull null]) {
        previousUser = nil;
    } else {
        previousUser = userUpdate.userInfo[@"previousValue"];
    }

    if (userUpdate.userInfo[@"currentValue"] == [NSNull null]) {
        currentUser = nil;
    } else {
        currentUser = userUpdate.userInfo[@"currentValue"];
    }

    NSString *previousAuthenticationLevel = [OTAuthService authenticationLevelForUser:previousUser];
    NSString *currentAuthenticationLevel = [OTAuthService authenticationLevelForUser:currentUser];

    if (![currentAuthenticationLevel isEqualToString:previousAuthenticationLevel]) {
        [FIRAnalytics setUserPropertyString:currentAuthenticationLevel forName:@"AuthenticationLevel"];
    }
    
    if (currentUser == nil && previousUser != nil) {
        for (NSString *key in previousUser.firebaseProperties) {
            // we try to unset the user properties after a logout, but it doesn't seem to work...
            [FIRAnalytics setUserPropertyString:nil forName:key];
        }
    }
    else if (![currentUser.firebaseProperties isEqualToDictionary:previousUser.firebaseProperties]) {
        for (NSString *key in currentUser.firebaseProperties) {
            [FIRAnalytics setUserPropertyString:currentUser.firebaseProperties[key] forName:key];
        }
    }
    
    if(currentUser != nil) {
        [FIRAnalytics setUserPropertyString:(currentUser.isEngaged ? @"Yes" : @"No") forName:@"engaged_user"];
        
        if (currentUser.isUserTypeNeighbour) {
            NSNumber *isExpert = [[NSUserDefaults standardUserDefaults]objectForKey:@"isExpertMode"];
            if (isExpert == nil) {
                BOOL isExpertMode = NO;
                if (currentUser.isEngaged) {
                    isExpertMode = YES;
                }
                [[NSUserDefaults standardUserDefaults] setBool:isExpertMode forKey:@"isExpertMode"];
                [FIRAnalytics setUserPropertyString:(isExpertMode ? @"Expert" : @"Neo") forName:@"home_view_mode"];
            }
            else {
                BOOL _isExp = isExpert.boolValue;
                [FIRAnalytics setUserPropertyString:(_isExp ? @"Expert" : @"Neo") forName:@"home_view_mode"];
            }
        }
    }
}

@end
