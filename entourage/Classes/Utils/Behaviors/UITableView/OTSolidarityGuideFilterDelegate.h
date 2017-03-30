//
//  OTSolidarityGuideFilterDelegate.h
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFilters.h"

@protocol OTFeedItemsFilterDelegate <NSObject>

@property (nonatomic, strong, readonly) OTFeedItemFilters *currentFilter;

- (void)filterChanged:(OTFeedItemFilters *)filter;

@end
