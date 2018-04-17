//
//  OTFeedItemsFiltersTableDataSource.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGroupedTableDataSourceBehavior.h"
#import "OTFeedItemFilters.h"

@interface OTFeedItemsFiltersTableDataSource : OTGroupedTableDataSourceBehavior

@property (nonatomic, strong) OTFeedItemFilters *currentFilter;

- (void)initializeWith:(OTFeedItemFilters *)filter;
- (OTFeedItemFilters *)readCurrentFilter;

@end
