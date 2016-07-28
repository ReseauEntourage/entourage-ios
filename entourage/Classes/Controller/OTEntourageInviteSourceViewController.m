//
//  OTEntourageInviteSourceViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageInviteSourceViewController.h"
#import "UIView+entourage.h"

@interface OTEntourageInviteSourceViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnInviteContacts;
@property (weak, nonatomic) IBOutlet UIButton *btnInviteByPhone;

@end

@implementation OTEntourageInviteSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.btnInviteContacts setupHalfRoundedCorners];
    [self.btnInviteByPhone setupHalfRoundedCorners];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inviteContacts:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate)
        [self.delegate inviteContacts];
}

- (IBAction)inviteByPhone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate)
        [self.delegate inviteByPhone];
}

@end
