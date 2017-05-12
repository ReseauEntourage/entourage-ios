//
//  OTAssociationTableViewCell.m
//  entourage
//
//  Created by sergiu buceac on 1/17/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAssociationTableViewCell.h"
#import "UIButton+entourage.h"

#define SELECTED_IMAGE @"24HSelected"
#define UNSELECTED_IMAGE @"24HInactive"

#define NAME_FONT_SIZE 15

@implementation OTAssociationTableViewCell

- (void)configureWith:(OTAssociation *)association {
    [self.btnLogo setupAsProfilePictureFromUrl:association.largeLogoUrl withPlaceholder:@"badgeDefault"];
    NSString *fontName = association.isDefault ? @"SFUIText-Bold" : @"SFUIText-Light";
    self.lblName.font = [UIFont fontWithName:fontName size:NAME_FONT_SIZE];
    self.lblName.text = association.name;
    self.imgSelected.image = [[UIImage imageNamed:(association.isDefault ? SELECTED_IMAGE : UNSELECTED_IMAGE)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (IBAction)showAssociationDetails:(id)sender {
    [self.owner performSegueWithIdentifier:@"AssociationDetails" sender:self];
}

@end
