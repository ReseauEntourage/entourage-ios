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
    
    return [NSString stringWithFormat:@"%ldh%02ld", (long)hour, (long)minute];
}

- (NSString *)toRoundedQuarterTimeString {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger roundMin = minute % 15;
    NSInteger min = minute - roundMin;
    
    if (min == 0) {
        return [NSString stringWithFormat:@"%ldh", (long)hour];
    }
    
    return [NSString stringWithFormat:@"%ldh%ld", (long)hour, (long)(min)];
}

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate
{
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:aDate];
    return ((components1.year == components2.year) && (components1.month == components2.month) && (components1.day == components2.day));
}

- (BOOL)isToday
{
    return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)isYesterday
{
    return [self isEqualToDateIgnoringTime:[self dateYesterday]];
}

- (NSDate *)dateYesterday
{
    return [self dateByAddingDays:-1];
}

- (NSDate *)dateByAddingDays:(NSInteger)dDays
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dDays];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSString*)asStringWithFormat:(NSString*)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

@end
