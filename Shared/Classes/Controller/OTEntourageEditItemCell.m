//
//  OTEntourageEditItemCell.m
//  entourage
//
//  Created by sergiu.buceac on 17/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEntourageEditItemCell.h"
#import "entourage-Swift.h"

@implementation OTEntourageEditItemCell

- (void)configureWith:(NSString *)title andText:(NSString *)description {
    self.lblTitle.text = title;
    self.lblDescription.text = description;
    self.lblDescription.textColor = [ApplicationTheme shared].backgroundThemeColor;
}

- (void)configureWithTitle:(NSString *)title
               description:(NSString*)description
                 isPrivate:(BOOL)isPrivate {
    self.lblTitle.text = title;
    self.lblDescription.text = description;
    [self.privacySwitch setOn:isPrivate];
    self.privacySwitch.enabled = NO;
}

@end
