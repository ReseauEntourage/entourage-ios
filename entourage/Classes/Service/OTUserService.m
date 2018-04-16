//
//  OTUserService.m
//  entourage
//
//  Created by Veronica on 14/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTUserService.h"
#import "OTAPIConsts.h"
#import "NSUserDefaults+OT.h"
#import "OTHTTPRequestManager.h"

@implementation OTUserService

- (void)reportUser:(NSString*)idString
            message:(NSString*)message
           success:(void (^)(OTUser *onboardUser))success
           failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{@"user_report":@{@"message":message}};
    
    NSString *url = [NSString stringWithFormat:API_URL_REPORT_USER, idString, TOKEN];
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:url
     andParameters:parameters
     andSuccess:^(id responseObject) {
        
     }
     andFailure:^(NSError *error) {
         if (failure) {
             failure(error);
         }
     }
     ];
}


@end
