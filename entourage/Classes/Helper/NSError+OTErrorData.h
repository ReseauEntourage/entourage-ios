//
//  NSError+OTErrorData.h
//  entourage
//
//  Created by sergiu buceac on 10/18/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (OTErrorData)

- (NSDictionary *)getErrorDictionary;
- (NSString *)readErrorCode;
- (NSString *)readErrorStatus;

@end
