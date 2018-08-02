//
//  OTFeedItemFiltersCellProvider.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemFiltersCellProvider.h"
#import "OTDataSourceBehavior.h"
#import "OTFeedItemsFilterCellBase.h"
#import "OTFeedItemFilter.h"
#import "OTFeedItemTimeframeFilter.h"
#import "OTFeedItemsTimeframeCell.h"
#import "OTImageFeedItemsFilterCell.h"
#import "OTFeedItemsFilterCell.h"

@implementation OTFeedItemFiltersCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTFeedItemFilter *filterItem = [self.tableDataSource getItemAtIndexPath:indexPath];
    NSString *identifier = [self getIdentifierForFilter:filterItem];
    
    OTFeedItemsFilterCellBase *cell = (OTFeedItemsFilterCellBase *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configureWith:filterItem];
    
    return cell;
}

#pragma mark - private methods

- (NSString *)getIdentifierForFilter:(OTFeedItemFilter *)filter {
    if([filter isKindOfClass:[OTFeedItemTimeframeFilter class]])
        return @"TimeframeCell";
    return filter.image ? @"ImageFilterCell" : @"FilterCell";
}

@end
