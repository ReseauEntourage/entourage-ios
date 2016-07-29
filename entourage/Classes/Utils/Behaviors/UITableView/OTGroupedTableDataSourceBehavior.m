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
    NSString *key = [self.quickJumpList objectAtIndex:indexPath.section];
    NSArray *items = [self.groupedSource objectForKey:key];
    return [items objectAtIndex:indexPath.row];
}

- (void)refresh {
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.quickJumpList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.quickJumpList objectAtIndex:section];
    NSArray *items = [self.groupedSource objectForKey:key];
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.quickJumpList objectAtIndex:section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.quickJumpList;
}

@end
