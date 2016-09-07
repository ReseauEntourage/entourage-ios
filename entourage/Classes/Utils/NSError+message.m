//
//  NSError+NSError_uimessage.m
//  entourage
//
//  Created by sergiu buceac on 7/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "NSError+message.h"
#import "OTConsts.h"

#define UNAUTHORIZED_CODE @"UNAUTHORIZED"
#define ALREADY_EXISTS_CODE @"PHONE_ALREADY_EXIST"

@implementation NSError (message)

- (NSString *)userUpdateMessage {
    NSDictionary *userInfo = [self userInfo];
    NSString *errorMessage = @"";
    NSDictionary *errorDictionary = [userInfo objectForKey:@"NSLocalizedDescription"];
    NSString *code = [errorDictionary valueForKey:@"code"];
    if([code caseInsensitiveCompare:UNAUTHORIZED_CODE] == NSOrderedSame)
        return OTLocalizedString(@"invalidCode");
    else if([code caseInsensitiveCompare:ALREADY_EXISTS_CODE] == NSOrderedSame)
        return nil;
    if (errorDictionary)
        errorMessage = ((NSArray*)[errorDictionary valueForKey:@"message"]).firstObject;
    return errorMessage;
}

@end
