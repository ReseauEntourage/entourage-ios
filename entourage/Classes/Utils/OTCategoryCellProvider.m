//
//  OTCategoryCellProvider.m
//  entourage
//
//  Created by veronica.gliga on 25/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCategoryCellProvider.h"
#import "OTCategoryEditCell.h"
#import "OTDataSourceBehavior.h"

@implementation OTCategoryCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTCategoryType *item = [self.tableDataSource getItemAtIndexPath:indexPath];
    OTCategory *itemCategory = item.categories[indexPath.row];
    OTCategoryEditCell *cell = (OTCategoryEditCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    [cell configureWith:itemCategory];
    return cell;
}

@end
