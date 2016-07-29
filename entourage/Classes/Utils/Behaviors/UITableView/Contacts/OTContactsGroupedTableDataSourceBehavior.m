//
//  OTContactsGroupedTableDataSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTContactsGroupedTableDataSourceBehavior.h"
#import "OTAddressBookItem.h"
#import "OTDataSourceBehavior.h"

@implementation OTContactsGroupedTableDataSourceBehavior

- (void)refresh {
    NSMutableArray *sections = [NSMutableArray new];
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *index = nil;
    for (OTAddressBookItem *item in self.dataSource.items) {
        NSString *currentIndex = [item.fullName substringToIndex:1];
        if(!index || ![index isEqualToString:currentIndex]) {
            index = currentIndex;
            [sections addObject:currentIndex];
        }
        NSMutableArray *array = [data objectForKey:currentIndex];
        if(!array) {
            array = [NSMutableArray new];
            [data setObject:array forKey:currentIndex];
        }
        [array addObject:item];
    }
    self.groupedSource = data;
    self.quickJumpList = sections;
    [self.dataSource.tableView reloadData];
}

@end
