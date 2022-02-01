//
//  OTAddressBookItem.h
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTAddressBookItem : NSObject

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSArray *phoneNumbers;

@end
