//
//  OTInviteCell.m
//  entourage
//
//  Created by Veronica on 30/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTInviteCell.h"
#import "entourage-Swift.h"

@implementation OTInviteCell

- (void)configureWith:(id)item {
    if ([OTAppConfiguration sharedInstance].environmentConfiguration.applicationType == ApplicationTypeVoisinAge) {
        [self.inviteLabel setText:@"en parler à un ami"];
    }
    else {
        [self.inviteLabel setText:@"inviter un ami"];
    }
    
    UIImage *image = [self.plusButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.inviteLabel setTextColor:[ApplicationTheme shared].primaryNavigationBarTintColor];
    [self.plusButton.imageView setTintColor:[ApplicationTheme shared].primaryNavigationBarTintColor];
    self.plusButton.imageView.image = image;
}
@end
