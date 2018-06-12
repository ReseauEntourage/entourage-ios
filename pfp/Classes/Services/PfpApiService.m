//
//  PfpApiService.m
//  pfp
//
//  Created by Smart Care on 06/06/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "PfpApiService.h"
#import "NSDictionary+Parsing.h"
#import "OTHTTPRequestManager.h"
#import "ISO8601DateFormatter.h"
#import "NSUserDefaults+OT.h"
#import "OTAPIConsts.h"

#define API_URL_PFP_SEND_LAST_VISIT_MESSAGE @"entourages/%@/chat_messages.json?token=%@"

@implementation PfpApiService

+ (void)sendLastVisit:(NSDate *)date
        privateCircle:(OTUserMembershipListItem*)circle
           completion:(void(^)(NSError *))completion
{
    NSString *url = [NSString stringWithFormat:API_URL_PFP_SEND_LAST_VISIT_MESSAGE, circle.id, TOKEN];
    
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    formatter.includeTime = YES;
    NSString *dateString = [formatter stringFromDate:date];
    NSDictionary *messageDictionary = @{@"chat_message" : @{@"message_type": @"visit", @"metadata":@{@"visited_at":dateString}}};
    
    [[OTHTTPRequestManager sharedInstance] POSTWithUrl:url
                                         andParameters:messageDictionary
                                            andSuccess:^(id responseObject) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (completion) {
                                                        completion(nil);
                                                    }
                                                });
                                            }
                                            andFailure:^(NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (completion) {
                                                        completion(error);
                                                    }
                                                });
                                            }
     ];
}

@end
