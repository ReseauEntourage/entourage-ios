//
//  OTGroupedTableSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGroupedTableSourceBehavior.h"

@interface OTGroupedTableSourceBehavior () <UITableViewDataSource>

@end

@implementation OTGroupedTableSourceBehavior

- (void)initialise {
    self.tableView.dataSource = self;
}

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self.quickJumpList objectAtIndex:indexPath.section];
    NSArray *items = [self.dataSource objectForKey:key];
    return [items objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.quickJumpList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self.quickJumpList objectAtIndex:section];
    NSArray *items = [self.dataSource objectForKey:key];
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.quickJumpList objectAtIndex:section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.quickJumpList;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataProviderBehavior getTableViewCellForPath:indexPath];
}

@end
