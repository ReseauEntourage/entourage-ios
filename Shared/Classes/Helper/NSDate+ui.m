//
//  NSDate+ui.m
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "NSDate+ui.h"

@implementation NSDate (ui)

- (NSString *)sinceNow {
    double timeInterval = [[NSDate date] timeIntervalSinceDate:self];
    if(timeInterval < 60)
        return [NSString stringWithFormat:@"%ds", (int)timeInterval];
    timeInterval /= 60;
    if(timeInterval < 60)
        return [NSString stringWithFormat:@"%dm", (int)timeInterval];
    timeInterval /= 60;
    if(timeInterval < 24)
        return [NSString stringWithFormat:@"%dh", (int)timeInterval];
    timeInterval /= 24;
    return [NSString stringWithFormat:@"%dj", (int)timeInterval];
}

@end
