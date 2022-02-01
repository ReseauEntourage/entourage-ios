//
//  OTAddressBookService.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Contacts/Contacts.h>

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
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    if(contactStore == nil) {
        return @[];
    }
    NSArray *allAddressBookItems = [self mapContacts:contactStore];
    return [allAddressBookItems sortedArrayUsingComparator:^(OTAddressBookItem *first, OTAddressBookItem *second) {
        return [first.fullName localizedCaseInsensitiveCompare:second.fullName];
    }];
}

- (NSArray *)mapContacts:(CNContactStore*)contactStore {
    NSMutableArray *allAddressBookItems = [NSMutableArray new];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey]];
    @autoreleasepool {
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:NULL usingBlock:^(CNContact *contact, BOOL *stop){
            OTAddressBookItem *addressBookItem = [self mapRecordToItem:contact];
            if(addressBookItem)
                [allAddressBookItems addObject:addressBookItem];
        }];
    }
    return allAddressBookItems;
}

- (OTAddressBookItem *)mapRecordToItem:(CNContact*)record {
    OTAddressBookItem *addressBookItem = [OTAddressBookItem new];
    addressBookItem.phoneNumbers = [self readPhones:record];
    if(addressBookItem.phoneNumbers.count == 0)
        return nil;
    addressBookItem.fullName = [CNContactFormatter stringFromContact:record style:CNContactFormatterStyleFullName];
    if(!addressBookItem.fullName || addressBookItem.fullName.length == 0)
        return nil;
    return addressBookItem;
}

- (NSArray *)readPhones:(CNContact*)record {
    NSMutableArray *result = [NSMutableArray new];
    for (CNLabeledValue<CNPhoneNumber*>* labeledPhone in record.phoneNumbers) {
        OTAddressBookPhone *phoneItem = [OTAddressBookPhone new];
        phoneItem.telephone = labeledPhone.value.stringValue;
        [result addObject:phoneItem];
    }
    return result;
}

@end
