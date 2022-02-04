//
//  OTFeedItemsFilterDelegate.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFilters.h"

@protocol OTFeedItemsFilterDelegate <NSObject>

@property (nonatomic, strong, readonly) OTFeedItemFilters *currentFilter;
@property (nonatomic, strong, readonly) OTFeedItemFilters *encounterFilter;
@property (nonatomic,readonly) BOOL isEncounterSelected;
- (void)filterChanged:(OTFeedItemFilters *)filter;

@end
