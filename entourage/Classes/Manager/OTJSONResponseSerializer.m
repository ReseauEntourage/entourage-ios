//
//  OTJSONResponseSerializer.m
//  entourage
//
//  Created by Ciprian Habuc on 30/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJSONResponseSerializer.h"

@implementation OTJSONResponseSerializer

+ (instancetype)serializer {
    return [super serializer];
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONObject = [super responseObjectForResponse:response data:data error:error];
    if (*error != nil) {
        NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
        if (data == nil) {
            userInfo[JSONResponseSerializerWithDataKey] = @"";
        } else {
            NSString *errorMessage = [JSONObject valueForKey:@"error"];
            if (errorMessage != nil) {
                userInfo[JSONResponseSerializerWithDataKey] = errorMessage;
            }
            NSLog(@"--->\nERR %@\n\n+++>JSON %@", userInfo, JSONObject);
        }
        NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
        (*error) = newError;
    }
    
    return (JSONObject);
}


@end
