//
//  OTMyEntouragesCellProvider.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTMyEntouragesCellProvider.h"
#import "OTEntouragesTableViewCell.h"
#import "OTDataSourceBehavior.h"

@implementation OTMyEntouragesCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTFeedItem *item = (OTFeedItem *)[self.tableDataSource getItemAtIndexPath:indexPath];
    
    OTEntouragesTableViewCell *cell = (OTEntouragesTableViewCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:@"EntourageCell"];
    [cell configureWith:item];
    return cell;
}

@end
