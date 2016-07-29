//
//  OTEntourageInviteByPhoneViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageInviteByPhoneViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "UITextField+indentation.h"

@interface OTEntourageInviteByPhoneViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (nonatomic, strong) UIBarButtonItem *btnSave;

@end

@implementation OTEntourageInviteByPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"mobilePhone").uppercaseString;
    self.btnSave = [UIBarButtonItem createWithTitle:OTLocalizedString(@"send") withTarget:self andAction:@selector(save) colored:[UIColor appOrangeColor]];
    [self.btnSave changeEnabled:NO];
    [self.navigationItem setRightBarButtonItem:self.btnSave];
    [self.txtPhone setupWithPlaceholderColor:[UIColor appGreyishColor] andFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    [self.txtPhone becomeFirstResponder];
}

#pragma mark - private members

- (void)save {
#warning TODO
}

@end
