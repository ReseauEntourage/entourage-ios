//
//  OTMyEntourageTimeframeFilter.h
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntourageFilter.h"

@interface OTMyEntourageTimeframeFilter : OTMyEntourageFilter

@property (nonatomic) int timeframeInHours;

+ (OTMyEntourageTimeframeFilter *)createFor:(MyEntourageFilterKey)key timeframeInHours:(int)timeframeInHours;

@end
