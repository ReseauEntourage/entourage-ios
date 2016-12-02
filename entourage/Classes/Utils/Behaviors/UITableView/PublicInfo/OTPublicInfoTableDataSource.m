//
//  OTPublicInfoTableDataSource.m
//  entourage
//
//  Created by sergiu buceac on 10/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicInfoTableDataSource.h"
#import "OTDataSourceBehavior.h"

@implementation OTPublicInfoTableDataSource

- (void)initialize {
    [super initialize];
    self.dataSource.tableView.tableFooterView = [UIView new];
}

@end
