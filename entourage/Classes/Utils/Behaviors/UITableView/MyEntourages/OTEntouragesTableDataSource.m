//
//  OTEntouragesTableDataSource.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntouragesTableDataSource.h"
#import "OTDataSourceBehavior.h"
#import "OTTableCellProviderBehavior.h"

@interface OTEntouragesTableDataSource () <UITableViewDelegate>

@end

@implementation OTEntouragesTableDataSource

- (void)initialize {
    [super initialize];
    self.dataSource.tableView.delegate = self;
}

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource.items objectAtIndex:indexPath.section];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource.items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellProvider getTableViewCellForPath:indexPath];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *v = [UIView new];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 15;
}

@end
