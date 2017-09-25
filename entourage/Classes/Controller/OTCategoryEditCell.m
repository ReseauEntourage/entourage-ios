//
//  OTCategoryEditCell.m
//  entourage
//
//  Created by veronica.gliga on 25/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCategoryEditCell.h"

#define SELECTED_IMAGE @"24HSelected"
#define UNSELECTED_IMAGE @"24HInactive"

@implementation OTCategoryEditCell

- (void)configureWith:(OTCategory *)category {
    self.lblTitle.text = category.title;
    self.selectedImage.image = [[UIImage imageNamed:(category.isSelected ? SELECTED_IMAGE : UNSELECTED_IMAGE)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
