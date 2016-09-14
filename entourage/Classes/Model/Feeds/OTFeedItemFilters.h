//
//  OTFeedItemFilters.h
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemFilter.h"
#import "OTUser.h"

#define PAGE_NUMBER_KEY @"page"
#define PAGE_SIZE_KEY @"per"
#define FILTER_TOUR_TYPES_KEY @"tour_types"
#define FILTER_ENTOURAGE_TYPES_KEY @"entourage_types"
#define TIMEFRAME_KEY @"time_range"

@interface OTFeedItemFilters : NSObject

@property (nonatomic, strong) OTUser *currentUser;

- (NSArray *)toGroupedArray;
- (NSArray *)groupHeaders;
- (NSMutableDictionary *)toDictionaryWithPageNumber:(int)pageNumber andSize:(int)pageSize;
- (void)updateValue:(OTFeedItemFilter *)filter;
- (NSArray *)timeframes;

@end
