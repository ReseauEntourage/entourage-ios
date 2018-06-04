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
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTAddressBookService.h"

@interface OTContactsFilteredDataSourceBehavior ()

@property (nonatomic, strong) NSMutableArray* items;
- (void)updateWithExpand:(NSArray *)colapsedItems;

@end

@implementation OTContactsFilteredDataSourceBehavior

@synthesize items;

- (void)filterItemsByString:(NSString *)searchString {
    if([searchString length] == 0)
        [self updateWithExpand:self.allItems];
    else
        [self updateWithExpand:[self.allItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(OTAddressBookItem *item, NSDictionary * bndings) {
            NSRange rangeValue = [item.fullName rangeOfString:searchString options:NSCaseInsensitiveSearch];
            BOOL contains = rangeValue.length > 0;
            return contains;
        }]]];
    [self.tableDataSource refresh];
}

- (void)updateWithExpand:(NSArray *)colapsedItems {
    [super updateItems:colapsedItems];
    NSMutableArray *expandedItems = [NSMutableArray new];
    for(OTAddressBookItem *item in colapsedItems) {
        [expandedItems addObject:item];
        [expandedItems addObjectsFromArray:item.phoneNumbers];
    }
    self.items = expandedItems;
    [self.tableDataSource refresh];
}

- (void)loadData {
    [SVProgressHUD show];
    [[OTAddressBookService new] readWithResultBlock:^(NSArray *results) {
        [self updateWithExpand:results];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
}

@end
