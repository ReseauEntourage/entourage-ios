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
    timeInterval /= 3600;
    if(timeInterval > 24) {
        timeInterval /= 24;
        return [NSString stringWithFormat:@"%dd", (int)timeInterval];
    }
    return [NSString stringWithFormat:@"%dh", (int)timeInterval];
}

@end
