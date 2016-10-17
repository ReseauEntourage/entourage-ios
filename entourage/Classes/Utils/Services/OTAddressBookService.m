//
//  OTAddressBookService.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTAddressBookService.h"
#import "OTAddressBookItem.h"
#import "OTAddressBookPhone.h"
#import "NSString+Validators.h"
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
    addressBookItem.phoneNumbers = [self readPhones:record];
    if(addressBookItem.phoneNumbers.count == 0)
        return nil;
    addressBookItem.fullName = [self readFullName:record];
    if(!addressBookItem.fullName || addressBookItem.fullName.length == 0)
        return nil;
    return addressBookItem;
}

- (NSString *)readFullName:(ABRecordRef)record {
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName ? firstName : @"", lastName ? lastName : @""];
    if(!fullName || [fullName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]].length == 0)
        return nil;
    return fullName;
}

- (NSArray *)readPhones:(ABRecordRef)record {
    NSMutableArray *result = [NSMutableArray new];
    ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(record, kABPersonPhoneProperty));
    NSString *readPhone = nil;
    for(CFIndex phoneIndex = 0; phoneIndex < ABMultiValueGetCount(phones); phoneIndex++) {
#warning Sergiu : check if this should be kept after i see the design
        //NSString *mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, phoneIndex);
        readPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, phoneIndex);
        OTAddressBookPhone *phoneItem = [OTAddressBookPhone new];
        phoneItem.telephone = readPhone;
        [result addObject:phoneItem];
    }
    return result;
}

@end
