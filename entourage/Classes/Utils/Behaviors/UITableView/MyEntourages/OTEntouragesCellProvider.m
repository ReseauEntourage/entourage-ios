//
//  OTEntouragesCellProvider.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntouragesCellProvider.h"
#import "OTEntouragesTableViewCell.h"
#import "OTDataSourceBehavior.h"

@implementation OTEntouragesCellProvider

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    OTEntouragesTableViewCell *cell = (OTEntouragesTableViewCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:@"EntourageCell"];
    return cell;
}

@end
