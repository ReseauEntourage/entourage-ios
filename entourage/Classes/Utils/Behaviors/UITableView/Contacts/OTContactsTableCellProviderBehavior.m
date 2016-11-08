//
//  OTContactsTableCellProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 7/29/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTContactsTableCellProviderBehavior.h"
#import "OTAddressBookItem.h"
#import "OTAddressBookPhone.h"
#import "OTContactInfoCell.h"
#import "OTContactPhoneCell.h"
#import "OTDataSourceBehavior.h"

@implementation OTContactsTableCellProviderBehavior

- (UITableViewCell *)getTableViewCellForPath:(NSIndexPath *)indexPath {
    id item = [self.tableDataSource getItemAtIndexPath:indexPath];
    NSString *identifier = [self getCellIdentifier:item];
    UITableViewCell *cell = [self.tableDataSource.dataSource.tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell withItem:item];
    return cell;
}

#pragma mark - private methods

- (NSString *)getCellIdentifier:(id)item {
    if([self isContactInfo:item])
        return @"ContactCell";
    return @"PhoneCell";
}

- (void)configureCell:(UITableViewCell *)cell withItem:(id)item {
    if([self isContactInfo:item]) {
        OTContactInfoCell *contactCell = (OTContactInfoCell *)cell;
        [contactCell configureWith:(OTAddressBookItem *)item];
    }
    else {
        OTContactPhoneCell *phoneCell = (OTContactPhoneCell *)cell;
        [phoneCell configureWith:(OTAddressBookPhone *)item];
    }
    
}

- (BOOL)isContactInfo:(id)item {
    return [item isKindOfClass:[OTAddressBookItem class]];
}

@end
