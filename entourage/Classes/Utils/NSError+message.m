//
//  NSError+NSError_uimessage.m
//  entourage
//
//  Created by sergiu buceac on 7/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "NSError+message.h"

@implementation NSError (message)

- (NSString *)userUpdateMessage {
    NSDictionary *userInfo = [self userInfo];
    NSString *errorMessage = @"";
    NSDictionary *errorDictionary = [userInfo objectForKey:@"NSLocalizedDescription"];
    //NSString *code = [errorDictionary valueForKey:@"code"];
    if (errorDictionary)
        errorMessage = ((NSArray*)[errorDictionary valueForKey:@"message"]).firstObject;
    return errorMessage;
}

@end
