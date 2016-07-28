//
//  OTAddressBookService.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTAddressBookService.h"
#import "OTAddressBookItem.h"
@import AddressBook;

@implementation OTAddressBookService

- (void)readWithResultBlock:(void (^)(NSArray *))result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *contacts = [self readContacts];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(result)
                result(contacts);
        });
    });
}

- (NSArray *)readContacts {
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if(error)
        return [NSArray new];
    NSArray *allAddressBookItems = [self mapContacts:addressBook];
    return [allAddressBookItems sortedArrayUsingComparator:^(OTAddressBookItem *first, OTAddressBookItem *second) {
        return [first.fullName localizedCaseInsensitiveCompare:second.fullName];
    }];
}

- (NSArray *)mapContacts:(ABAddressBookRef)addressBook {
    NSMutableArray *allAddressBookItems = [NSMutableArray new];
    @autoreleasepool {
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (int index = 0; index < [allContacts count]; index++) {
            ABRecordRef record = (__bridge ABRecordRef)allContacts[index];
            OTAddressBookItem *addressBookItem = [self mapRecordToItem:record];
            if(addressBookItem)
                [allAddressBookItems addObject:addressBookItem];
        }
    }
    return allAddressBookItems;
}

- (OTAddressBookItem *)mapRecordToItem:(ABRecordRef)record {
    OTAddressBookItem *addressBookItem = [OTAddressBookItem new];
    addressBookItem.fullName = [self readFullName:record];
    addressBookItem.telephone = [self readPhone:record];
    if(!addressBookItem.fullName || !addressBookItem.telephone)
        return nil;
    return addressBookItem;
}

- (NSString *)readFullName:(ABRecordRef)record {
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
    if(!firstName || [firstName isEqualToString:@""])
        return nil;
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
    if(!lastName || [lastName isEqualToString:@""])
        return nil;
    return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

- (NSString *)readPhone:(ABRecordRef)record {
    NSString *phone = @"";
    ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(record, kABPersonPhoneProperty));
    for(CFIndex phoneIndex = 0; phoneIndex < ABMultiValueGetCount(phones); phoneIndex++) {
        NSString *mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, phoneIndex);
        phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, phoneIndex);
        if(!phone)
            continue;
        if([phone isEqualToString:@""])
            continue;
        if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            break;
    }
    return phone;
}

@end
