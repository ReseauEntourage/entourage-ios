//
//  NSDate+OTFormatter.h
//  entourage
//
//  Created by sergiu.buceac on 24/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (OTFormatter)

- (NSString *)toTimeString;
- (NSString*)asStringWithFormat:(NSString*)format;

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate;
- (BOOL)isToday;
- (BOOL)isYesterday;

@end
