//
//  OTMembersTableDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMembersTableDataSource.h"
#import "OTDataSourceBehavior.h"

@interface OTMembersTableDataSource () <UITableViewDelegate>

@end

@implementation OTMembersTableDataSource

- (void)initialize {
    [super initialize];
    self.dataSource.tableView.tableFooterView = [UIView new];
    self.dataSource.tableView.delegate = self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == self.dataSource.items.count - 1)
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
}

@end
