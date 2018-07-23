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

- (void)configureWithSwitchPublicState:(BOOL)public {
    if (!public) {
        self.lblTitle.text = @"Privé";
        self.lblDescription.text = @"Cette option sera bientôt disponible. En attendant, communiquez directement dans une conversation avec les personnes que vous souhaitez inviter.";
        [self.privacySwitch setOn:NO];
        
    } else {
        self.lblTitle.text = @"Public";
        self.lblDescription.text = @"Tous peuvent trouver la sortie dans le fil d'actualités, mais seuls les membres de mon voisinage sont notifiés.";
        [self.privacySwitch setOn:YES];
        [self.lblTitle setTextColor:[ApplicationTheme shared].titleLabelColor];
    }
    
    self.privacySwitch.enabled = NO;
}

@end
