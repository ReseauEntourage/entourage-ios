//
//  OTEntourageInviteSourceViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageInviteSourceViewController.h"

@interface OTEntourageInviteSourceViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnInviteContacts;
@property (weak, nonatomic) IBOutlet UIButton *btnInviteByPhone;

@end

@implementation OTEntourageInviteSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbarHidden = YES;
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
