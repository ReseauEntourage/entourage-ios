//
//  OTFeedItemsFilterCellBase.h
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemFilter.h"
#import "OTFeedItemsFiltersTableDataSource.h"

@interface OTFeedItemsFilterCellBase : UITableViewCell

@property (nonatomic, weak) IBOutlet OTFeedItemsFiltersTableDataSource* tableDataSource;

- (void)configureWith:(OTFeedItemFilter *)filter;

@end
