//
//  OTAssociationsSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAssociationsSourceBehavior.h"
#import "SVProgressHUD.h"
#import "OTAssociationsService.h"
#import "OTTableDataSourceBehavior.h"

@implementation OTAssociationsSourceBehavior

- (void)loadData {
    [SVProgressHUD show];
    [[OTAssociationsService new] getAllAssociationsWithSuccess:^(NSArray *items) {
        [SVProgressHUD dismiss];
        [self updateItems:items];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

@end
