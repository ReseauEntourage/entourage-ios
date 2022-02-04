//
//  OTContactInfoCell.m
//  entourage
//
//  Created by sergiu buceac on 9/19/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTContactInfoCell.h"

@implementation OTContactInfoCell

- (void)configureWith:(OTAddressBookItem *)item {
    self.lblFullName.text = item.fullName;
}

@end
