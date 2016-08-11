//
//  OTMyEntouragesFiltersCellProvider.m
//  entourage
//
//  Created by sergiu buceac on 8/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesFiltersCellProvider.h"
#import "OTDataSourceBehavior.h"
#import "OTMyEntouragesFilterCell.h"
#import "OTMyEntourageFilter.h"

@implementation OTMyEntouragesFiltersCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTMyEntourageFilter *filterItem = [self.tableDataSource getItemAtIndexPath:indexPath];
    OTMyEntouragesFilterCell *cell = (OTMyEntouragesFilterCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:@"MyEntouragesFilterCell"];
    [cell configureWith:filterItem];
    return cell;
}

@end
