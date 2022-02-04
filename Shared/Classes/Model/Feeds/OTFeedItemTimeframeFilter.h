//
//  OTFeedItemTimeframeFilter.h
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTFeedItemFilter.h"

@interface OTFeedItemTimeframeFilter : OTFeedItemFilter

@property (nonatomic) int timeframeInHours;

+ (OTFeedItemTimeframeFilter *)createFor:(FeedItemFilterKey)key timeframeInHours:(int)timeframeInHours;

@end
