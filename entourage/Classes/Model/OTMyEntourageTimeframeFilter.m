//
//  OTMyEntourageTimeframeFilter.m
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntourageTimeframeFilter.h"

@implementation OTMyEntourageTimeframeFilter

+ (OTMyEntourageTimeframeFilter *)createFor:(MyEntourageFilterKey)key timeframeInHours:(int)timeframeInHours {
    OTMyEntourageTimeframeFilter *result = [OTMyEntourageTimeframeFilter new];
    result.key = MyEntourageFilterKeyTimeframe;
    result.timeframeInHours = timeframeInHours;
    return result;
}

- (void)change:(OTMyEntouragesFilter *)filter {
    filter.timeframeInHours = self.timeframeInHours;
}

@end
