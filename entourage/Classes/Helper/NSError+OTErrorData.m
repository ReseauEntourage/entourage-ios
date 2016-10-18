//
//  NSError+OTErrorData.m
//  entourage
//
//  Created by sergiu buceac on 10/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "NSError+OTErrorData.h"
#import "OTJSONResponseSerializer.h"

#define ErrorKey @"error"
#define CodeKey @"code"
#define StatusKey @"status"

@implementation NSError (OTErrorData)

- (NSDictionary *)getErrorDictionary {
    id fullDict = [self.userInfo objectForKey:JSONResponseSerializerFullDictKey];
    if(fullDict && [fullDict isKindOfClass:[NSDictionary class]])
        return fullDict;
    return nil;
}

- (NSString *)readErrorCode {
    NSDictionary *dictionary = [self getErrorDictionary];
    if(dictionary) {
        id errorDict = [dictionary objectForKey:ErrorKey];
        if(errorDict && [errorDict isKindOfClass:[NSDictionary class]])
            return [errorDict objectForKey:CodeKey];
    }
    return @"";
}

- (NSString *)readErrorStatus {
    NSDictionary *dictionary = [self getErrorDictionary];
    if(dictionary)
        return [dictionary objectForKey:StatusKey];
    return @"";
}

@end
