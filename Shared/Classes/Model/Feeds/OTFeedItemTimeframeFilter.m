//
//  OTFeedItemTimeframeFilter.m
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemTimeframeFilter.h"

@implementation OTFeedItemTimeframeFilter

+ (OTFeedItemTimeframeFilter *)createFor:(FeedItemFilterKey)key timeframeInHours:(int)timeframeInHours {
    OTFeedItemTimeframeFilter *result = [OTFeedItemTimeframeFilter new];
    result.key = FeedItemFilterKeyTimeframe;
    result.timeframeInHours = timeframeInHours;
    return result;
}

@end
