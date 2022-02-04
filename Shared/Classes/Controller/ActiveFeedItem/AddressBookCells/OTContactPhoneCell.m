//
//  OTContactPhoneCell.m
//  entourage
//
//  Created by sergiu buceac on 9/19/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTContactPhoneCell.h"

#define SELECTED_IMAGE @"24HSelected"
#define UNSELECTED_IMAGE @"24HInactive"

@implementation OTContactPhoneCell

- (void)configureWith:(OTAddressBookPhone *)phone {
    self.lblPhoneNumber.text = phone.telephone;
    self.imgSelectState.image = [[UIImage imageNamed:(phone.selected ? SELECTED_IMAGE : UNSELECTED_IMAGE)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
