//
//  OTInviteCell.m
//  entourage
//
//  Created by Veronica on 30/05/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTInviteCell.h"
#import "entourage-Swift.h"

@implementation OTInviteCell

- (void)configureWith:(id)item {
    [self.inviteLabel setText:@"inviter un ami"];
    
    UIImage *image = [self.plusButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.inviteLabel setTextColor:[ApplicationTheme shared].primaryNavigationBarTintColor];
    [self.plusButton.imageView setTintColor:[ApplicationTheme shared].primaryNavigationBarTintColor];
    self.plusButton.imageView.image = image;
}
@end
