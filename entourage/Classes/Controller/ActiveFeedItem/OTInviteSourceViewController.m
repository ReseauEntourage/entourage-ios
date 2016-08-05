//
//  OTInviteSourceViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInviteSourceViewController.h"
#import "UIView+entourage.h"

@interface OTInviteSourceViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnInviteContacts;
@property (weak, nonatomic) IBOutlet UIButton *btnInviteByPhone;

@end

@implementation OTInviteSourceViewController

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
