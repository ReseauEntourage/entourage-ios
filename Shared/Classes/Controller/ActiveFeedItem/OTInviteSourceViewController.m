//
//  OTInviteSourceViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTInviteSourceViewController.h"
#import "UIView+entourage.h"
#import "entourage-Swift.h"

@implementation OTInviteSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // [self updateUIElements];
    [self setupViews];
    [OTLogger logEvent:Show_Pop_Share];
}

-(void) setupViews {
    self.inviteSubtitleLabel.text = [OTAppAppearance inviteSubtitleText:self.feedItem];
    
    for (UIButton *button in self.buttons) {
        button.layer.cornerRadius = 5;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [[UIColor appOrangeColor] CGColor];
    }
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
    
    self.inviteSubtitleLabel.text = [OTAppAppearance inviteSubtitleText:self.feedItem];
}

- (IBAction)close:(id)sender {
    [OTLogger logEvent:@"InviteFriendsClose"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inviteContacts:(id)sender {
    UIViewController *presentingViewController = self.presentingViewController;
    [OTLogger logEvent:@"InviteContacts"];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate)
        [self.delegate inviteContactsFromViewController:presentingViewController];
}

- (IBAction)inviteByPhone:(id)sender {
    [OTLogger logEvent:@"InviteByPhoneNumber"];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate)
        [self.delegate inviteByPhone];
}

- (IBAction)action_share:(id)sender {
    [OTLogger logEvent:Action_Pop_Share_Link];
    
    if(self.delegate)
        [self.delegate share];
}

- (IBAction)action_share_entourage:(id)sender {
    [OTLogger logEvent:Action_Pop_Share_Entourage];
    
    if(self.delegate) {
       [self.delegate shareEntourage];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
