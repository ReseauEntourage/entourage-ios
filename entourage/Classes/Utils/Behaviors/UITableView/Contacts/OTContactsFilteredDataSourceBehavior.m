//
//  OTContactsFilteredDataSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTContactsFilteredDataSourceBehavior.h"
#import "OTAddressBookItem.h"
#import "OTTableDataSourceBehavior.h"
#import "SVProgressHUD.h"
#import "OTAddressBookService.h"

@implementation OTContactsFilteredDataSourceBehavior

- (void)filterItemsByString:(NSString *)searchString {
    if([searchString length] == 0)
        [self updateItems:self.allItems];
    else
        [self updateItems:[self.allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(OTAddressBookItem *item, NSDictionary * bndings) {
            NSRange rangeValue = [item.fullName rangeOfString:searchString options:NSCaseInsensitiveSearch];
            BOOL contains = rangeValue.length > 0;
            return contains;
        }]]];
    [self.tableDataSource refresh];
}

- (void)updateItems:(NSArray *)items {
    [super updateItems:items];
    [self.tableDataSource refresh];
}

- (void)loadData {
    [SVProgressHUD show];
    [[OTAddressBookService new] readWithResultBlock:^(NSArray *results) {
        [self updateItems:results];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
}

@end
