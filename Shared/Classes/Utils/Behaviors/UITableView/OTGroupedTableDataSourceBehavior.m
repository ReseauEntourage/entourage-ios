//
//  OTGroupedTableSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGroupedTableDataSourceBehavior.h"

@implementation OTGroupedTableDataSourceBehavior

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *items = self.groupedSource[indexPath.section];
    return [items objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.groupHeaders count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = self.groupedSource[section];
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.groupHeaders objectAtIndex:section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.groupHeaders;
}

@end