//
//  OTMixpanelService.m
//  entourage
//
//  Created by veronica.gliga on 15/12/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTMixpanelService.h"
#import "OTHTTPRequestManager.h"
#import "OTAPIConsts.h"

@implementation OTMixpanelService

- (void)sendTokenDataWithDictionary:(NSDictionary *)dictionary
                            success:(void (^)(void))success
                            failure:(void (^)(NSError *))failure
{
    NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [json base64EncodedStringWithOptions:0];
    NSString *urlToSend = [NSString stringWithFormat:API_URL_MIXPANEL_ENGAGE, jsonString];
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:urlToSend
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         if (success) {
             success();
         }
     }
     andFailure:^(NSError *error)
     {
         NSLog(@"Failed with error %@", error);
         if (failure) {
             failure(error);
         }
     }];
}

@end
