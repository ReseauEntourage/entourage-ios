//
//  OTAssociationTableViewCell.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAssociationTableViewCell.h"
#import "UIImageView+entourage.h"

#define SELECTED_IMAGE @"24HSelected"
#define UNSELECTED_IMAGE @"24HInactive"

@implementation OTAssociationTableViewCell

- (void)configureWith:(OTAssociation *)association {
#warning TODO uncomment for correct url
    //[self.imgLogo setupFromUrl:association.logoUrl withPlaceholder:nil];
    [self.imgLogo setupFromUrl:@"http://icons.iconarchive.com/icons/pelfusion/flat-file-type/128/jpg-icon.png" withPlaceholder:nil];
    self.lblName.text = association.name;
    self.imgSelected.image = [[UIImage imageNamed:(association.isDefault ? SELECTED_IMAGE : UNSELECTED_IMAGE)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
