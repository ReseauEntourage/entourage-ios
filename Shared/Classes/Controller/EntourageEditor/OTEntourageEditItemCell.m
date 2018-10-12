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

- (void)configureWithSwitchPublicState:(BOOL)isPublic entourage:(OTEntourage*)entourage {
    if (isPublic) {
        self.lblTitle.text = @"Public";
        [self.privacySwitch setOn:YES];
        
    } else {
        self.lblTitle.text = @"Privé";
        [self.privacySwitch setOn:NO];
    }
    
    [self.lblTitle setTextColor:[ApplicationTheme shared].titleLabelColor];
    self.lblDescription.text = [OTAppAppearance entourageConfidentialityDescription:entourage isPublic:isPublic];
    
    self.privacySwitch.enabled = YES;
}

@end
