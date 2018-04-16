//
//  OTEntourageEditItemCell.m
//  entourage
//
//  Created by sergiu.buceac on 17/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEntourageEditItemCell.h"

@implementation OTEntourageEditItemCell

- (void)configureWith:(NSString *)title andText:(NSString *)description {
    self.lblTitle.text = title;
    self.lblDescription.text = description;
}

@end
