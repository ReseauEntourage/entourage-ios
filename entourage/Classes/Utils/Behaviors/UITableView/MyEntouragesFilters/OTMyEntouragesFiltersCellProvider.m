//
//  OTMyEntouragesFiltersCellProvider.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesFiltersCellProvider.h"
#import "OTDataSourceBehavior.h"
#import "OTMyEntouragesFilterCellBase.h"
#import "OTMyEntourageFilter.h"

@implementation OTMyEntouragesFiltersCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTMyEntourageFilter *filterItem = [self.tableDataSource getItemAtIndexPath:indexPath];
    NSString *identifier = filterItem.key == MyEntourageFilterKeyTimeframe ? @"TimeframeCell" : @"FilterCell";
    OTMyEntouragesFilterCellBase *cell = (OTMyEntouragesFilterCellBase *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configureWith:filterItem];
    return cell;
}

@end
