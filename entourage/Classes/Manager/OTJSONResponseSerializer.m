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
            userInfo[JSONResponseSerializerFullKey] = @"";
        } else {
            NSString* dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"response data: %@", dataString);
            userInfo[JSONResponseSerializerFullKey] = dataString;
            NSString *errorMessage = [JSONObject valueForKey:@"message"];
            if (errorMessage != nil)
                userInfo[JSONResponseSerializerWithDataKey] = errorMessage;
        }
        NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
        (*error) = newError;
    }
    
    return (JSONObject);
}


@end
