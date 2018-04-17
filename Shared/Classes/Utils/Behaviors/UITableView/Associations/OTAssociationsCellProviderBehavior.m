//
//  OTAssociationsCellProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAssociationsCellProviderBehavior.h"
#import "OTAssociationTableViewCell.h"
#import "OTDataSourceBehavior.h"

@implementation OTAssociationsCellProviderBehavior

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    id item = [self.tableDataSource getItemAtIndexPath:indexPath];
    OTAssociationTableViewCell *cell = (OTAssociationTableViewCell *)[self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:@"AssociationCell"];
    [cell configureWith:item];
    return cell;
}

@end
