//
//  NSDate+OTFormatter.m
//  entourage
//
//  Created by sergiu.buceac on 24/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "NSDate+OTFormatter.h"

@implementation NSDate (OTFormatter)

- (NSString *)toTimeString {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    return [NSString stringWithFormat:@"%ldh%ld", (long)hour, (long)minute];
}

@end
