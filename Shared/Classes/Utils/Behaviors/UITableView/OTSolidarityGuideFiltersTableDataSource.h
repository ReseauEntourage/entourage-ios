//
//  OTSolidarityGuideFiltersTableDataSource.h
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTGroupedTableDataSourceBehavior.h"
#import "OTSolidarityGuideFilter.h"

@interface OTSolidarityGuideFiltersTableDataSource : OTGroupedTableDataSourceBehavior

@property (nonatomic, strong) OTSolidarityGuideFilter *currentFilter;

- (void)initializeWith:(OTSolidarityGuideFilter *)filter;
- (OTSolidarityGuideFilter *)readCurrentFilter;

@end
