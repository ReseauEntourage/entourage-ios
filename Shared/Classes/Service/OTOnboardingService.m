//
//  OTOnboardingService.m
//  entourage
//
//  Created by Ciprian Habuc on 07/07/16.
//  Copyright © 2016 Entourage. All rights reserved.
//
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@import FacebookCore;

#import "OTOnboardingService.h"
#import "OTHTTPRequestManager.h"
#import "OTAPIConsts.h"
#import "OTAPIKeys.h"


@implementation OTOnboardingService


- (void)setupNewUserWithPhone:(NSString*)phone
                          success:(void (^)(OTUser *onboardUser))success
                          failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{@"user":@{@"phone":phone}};
    
    NSString *url = [NSString stringWithFormat:API_URL_ONBOARD];
    [[OTHTTPRequestManager sharedInstance]
         POSTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject) {
             NSDictionary *data = responseObject;
             NSDictionary *userDictionary = [data objectForKey:@"user"];
             OTUser *onboardedUser = nil;
             if (userDictionary)
                 onboardedUser = [[OTUser alloc] initWithDictionary:userDictionary];
             if (success) {
                 success(onboardedUser);
             }
             // send a facebook event
             NSDictionary *params = @{FBSDKAppEventParameterNameRegistrationMethod : @"entourage"};
             [FBSDKAppEvents
              logEvent:FBSDKAppEventNameCompletedRegistration
              parameters:params];
         }
         andFailure:^(NSError *error) {
             if (failure) {
                 failure(error);
             }
         }
     ];
}
- (void)setupNewUserWithUser:(OTUser*)user
                          success:(void (^)(OTUser *onboardUser))success
                          failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{@"user":@{@"phone":user.phone,@"first_name":user.firstName,@"last_name":user.lastName}};
    
    NSString *url = [NSString stringWithFormat:API_URL_ONBOARD];
    [[OTHTTPRequestManager sharedInstance]
         POSTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject) {
             NSDictionary *data = responseObject;
             NSDictionary *userDictionary = [data objectForKey:@"user"];
             OTUser *onboardedUser = nil;
             if (userDictionary)
                 onboardedUser = [[OTUser alloc] initWithDictionary:userDictionary];
             if (success) {
                 success(onboardedUser);
             }
             // send a facebook event
             NSDictionary *params = @{FBSDKAppEventParameterNameRegistrationMethod : @"entourage"};
             [FBSDKAppEvents
              logEvent:FBSDKAppEventNameCompletedRegistration
              parameters:params];
         }
         andFailure:^(NSError *error) {
             if (failure) {
                 failure(error);
             }
         }
     ];
}
@end
