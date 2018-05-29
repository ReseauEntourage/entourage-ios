//
//  OTInviteSourceViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInviteSourceViewController.h"
#import "UIView+entourage.h"
#import "entourage-Swift.h"

@implementation OTInviteSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUIElements];
}

- (void)updateUIElements {
    UIColor *color = [ApplicationTheme shared].backgroundThemeColor;
    self.popupContainerView.backgroundColor = color;
    
    for (UIButton *button in self.buttons) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    
    for (UIImageView *iconImageView in self.icons) {
        UIImage *image = [iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        iconImageView.tintColor = color;
        iconImageView.image = image;
    }
}

- (IBAction)close:(id)sender {
    [OTLogger logEvent:@"InviteFriendsClose"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inviteContacts:(id)sender {
    [OTLogger logEvent:@"InviteContacts"];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate)
        [self.delegate inviteContacts];
}

- (IBAction)inviteByPhone:(id)sender {
    [OTLogger logEvent:@"InviteByPhoneNumber"];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate)
        [self.delegate inviteByPhone];
}

- (IBAction)share:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate)
        [self.delegate share];
}

@end
