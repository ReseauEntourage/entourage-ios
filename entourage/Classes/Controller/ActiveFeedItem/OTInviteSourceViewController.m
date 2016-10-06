//
//  OTInviteSourceViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInviteSourceViewController.h"
#import "UIView+entourage.h"

@implementation OTInviteSourceViewController

- (IBAction)close:(id)sender {
    [Flurry logEvent:@"InviteFriendsClose"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inviteContacts:(id)sender {
    [Flurry logEvent:@"InviteContacts"];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate)
        [self.delegate inviteContacts];
}

- (IBAction)inviteByPhone:(id)sender {
    [Flurry logEvent:@"InviteByPhoneNumber"];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate)
        [self.delegate inviteByPhone];
}

@end
