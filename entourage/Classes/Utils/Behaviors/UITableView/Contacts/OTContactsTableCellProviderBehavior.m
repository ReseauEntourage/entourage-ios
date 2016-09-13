//
//  OTContactsTableCellProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTContactsTableCellProviderBehavior.h"
#import "OTAddressBookItem.h"
#import "OTDataSourceBehavior.h"

#define FULLNAME_CELL_TAG 1
#define SELECTED_IMAGE_CELL_TAG 2
#define SELECTED_IMAGE @"24HSelected"
#define UNSELECTED_IMAGE @"24HInactive"

@implementation OTContactsTableCellProviderBehavior

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    OTAddressBookItem *addressBookItem = [self.tableDataSource getItemAtIndexPath:indexPath];
    UILabel *lblFullName = [cell viewWithTag:FULLNAME_CELL_TAG];
    lblFullName.text = addressBookItem.fullName;
    UIImageView *imgSelected = [cell viewWithTag:SELECTED_IMAGE_CELL_TAG];
    imgSelected.image = [[UIImage imageNamed:(addressBookItem.selected ? SELECTED_IMAGE : UNSELECTED_IMAGE)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return cell;
}

@end
