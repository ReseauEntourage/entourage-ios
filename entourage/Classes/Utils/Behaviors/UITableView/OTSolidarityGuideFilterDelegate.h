//
//  OTSolidarityGuideFilterDelegate.h
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTSolidarityGuideFilter.h"

@protocol OTSolidarityGuideFilterDelegate <NSObject>

@property (nonatomic, strong, readonly) OTSolidarityGuideFilter *solidarityFilter;

- (void)solidarityFilterChanged:(OTSolidarityGuideFilter *)filter;

@end
