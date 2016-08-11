//
//  OTMyEntouragesFiltersTableDataSource.h
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGroupedTableDataSourceBehavior.h"
#import "OTMyEntourageFilter.h"
#import "OTMyEntouragesFilter.h"

@interface OTMyEntouragesFiltersTableDataSource : OTGroupedTableDataSourceBehavior

- (void)initializeWith:(OTMyEntouragesFilter *)filter;
- (OTMyEntouragesFilter *)readCurrentFilter;

@end
