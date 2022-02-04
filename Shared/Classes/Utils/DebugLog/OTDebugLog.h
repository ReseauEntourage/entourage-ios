//
//  OTDebugLog.h
//  entourage
//
//  Created by sergiu buceac on 10/31/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTDebugLog : NSObject

+ (OTDebugLog*) sharedInstance;

- (void)setConsoleOutput;
- (void)log:(NSString *)message;
- (void)sendEmail;

@end
