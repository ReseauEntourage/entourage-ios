//
//  OTInviteByPhoneViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInviteByPhoneViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "UITextField+indentation.h"
#import "NSString+Validators.h"
#import "OTFeedItemFactory.h"
#import "SVProgressHUD.h"
#import "IQKeyboardManager.h"
#import "UIScrollView+entourage.h"

@interface OTInviteByPhoneViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (nonatomic, strong) UIBarButtonItem *btnSave;

@end

@implementation OTInviteByPhoneViewController

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

- (IBAction)txtPhone_EditingChanged:(id)sender {
    [self.btnSave changeEnabled:[self.txtPhone.text isValidPhoneNumber]];
}

#pragma mark - private members

- (void)save {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getMessaging] invitePhones:@[self.txtPhone.text] withSuccess:^() {
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
        if(self.delegate)
            [self.delegate didInviteWithSuccess];
    } orFailure:^(NSError *error, NSArray *failedNumbers) {
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc] initWithTitle:OTLocalizedString(@"error") message:OTLocalizedString(@"inviteByPhoneFailed") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }];
}

@end
