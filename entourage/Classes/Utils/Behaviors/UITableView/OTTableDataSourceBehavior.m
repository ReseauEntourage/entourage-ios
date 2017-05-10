//
//  OTTableDataSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTableDataSourceBehavior.h"
#import "OTDataSourceBehavior.h"
#import "OTTableCellProviderBehavior.h"

@implementation OTTableDataSourceBehavior

- (void)initialize {
    [self.dataSource initialize];
    self.dataSource.tableView.dataSource = self;
}

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource.items objectAtIndex:indexPath.row];
}

- (void)refresh {
    [self.dataSource.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellProvider getTableViewCellForPath:indexPath];
}



@end
