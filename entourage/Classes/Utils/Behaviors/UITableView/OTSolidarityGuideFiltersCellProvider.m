//
//  OTSolidarityGuideFiltersCellProvider.m
//  entourage
//
//  Created by veronica.gliga on 30/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSolidarityGuideFiltersCellProvider.h"
#import "OTSolidarityGuideFilter.h"
#import "OTSolidarityGuideFilterCell.h"
#import "OTTableDataSourceBehavior.h"
#import "OTDataSourceBehavior.h"

@implementation OTSolidarityGuideFiltersCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTSolidarityGuideFilterItem *filterItem = [self.tableDataSource getItemAtIndexPath:indexPath];
    NSString *identifier = @"ImageFilterCell";
    OTSolidarityGuideFilterCell *cell = (OTSolidarityGuideFilterCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configureWith:filterItem];
    return cell;
}

@end
