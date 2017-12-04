//
//  OTGroupedTableSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTTableDataSourceBehavior.h"
#import "OTFeedItemFilter.h"

@interface OTGroupedTableDataSourceBehavior : OTTableDataSourceBehavior

@property (nonatomic, strong) NSArray *groupedSource;
@property (nonatomic, strong) NSArray *groupHeaders;
@property (nonatomic, strong) NSArray<OTFeedItemFilter *> *parentArray;

@end
