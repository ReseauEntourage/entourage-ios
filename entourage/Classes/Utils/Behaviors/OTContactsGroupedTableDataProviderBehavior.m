//
//  OTContactsGroupedTableDataProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTContactsGroupedTableDataProviderBehavior.h"
#import "OTAddressBookItem.h"
#import "OTGroupedTableSourceBehavior.h"

#define FULLNAME_CELL_TAG 1
#define SELECTED_IMAGE_CELL_TAG 2
#define SELECTED_IMAGE @"24HSelected"
#define UNSELECTED_IMAGE @"24HInactive"

@implementation OTContactsGroupedTableDataProviderBehavior

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.groupedSource.tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    OTAddressBookItem *addressBookItem = [self.groupedSource getItemAtIndexPath:indexPath];
    UILabel *lblFullName = [cell viewWithTag:FULLNAME_CELL_TAG];
    lblFullName.text = addressBookItem.fullName;
    UIImageView *imgSelected = [cell viewWithTag:SELECTED_IMAGE_CELL_TAG];
    imgSelected.image = [[UIImage imageNamed:(addressBookItem.selected ? SELECTED_IMAGE : UNSELECTED_IMAGE)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return cell;
}

- (void)refreshSource:(NSArray *)items {
    NSMutableArray *sections = [NSMutableArray new];
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *index = nil;
    for (OTAddressBookItem *item in items) {
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
    self.groupedSource.dataSource = data;
    self.groupedSource.quickJumpList = sections;
}

@end
