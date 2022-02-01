//
//  OTFeedItemsFiltersTableDataSource.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTGroupedTableDataSourceBehavior.h"
#import "OTFeedItemFilters.h"

@interface OTFeedItemsFiltersTableDataSource : OTGroupedTableDataSourceBehavior

@property (nonatomic, strong) OTFeedItemFilters *currentFilter;

- (void)initializeWith:(OTFeedItemFilters *)filter;
- (void)initializeWith:(OTFeedItemFilters *)filter andIsalone:(BOOL) isAlone;
- (OTFeedItemFilters *)readCurrentFilter;
@property (nonatomic) BOOL isAlone;
@end
