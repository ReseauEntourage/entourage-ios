//
//  OTInviteByPhoneViewController.m
//  entourage
//
//  Created by sergiu buceac on 7/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

#import "OTInviteByPhoneViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "UITextField+indentation.h"
#import "NSString+Validators.h"
#import "OTFeedItemFactory.h"
#import "UIScrollView+entourage.h"
#import "entourage-Swift.h"

@interface OTInviteByPhoneViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (nonatomic, strong) UIBarButtonItem *btnSave;

@end

@implementation OTInviteByPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = OTLocalizedString(@"mobilePhone").uppercaseString;
    self.btnSave = [UIBarButtonItem createWithTitle:OTLocalizedString(@"send")
                                         withTarget:self
                                          andAction:@selector(save)
                                            andFont:@"SFUIText-Bold"
                                            colored:[ApplicationTheme shared].secondaryNavigationBarTintColor];
    [self.btnSave changeEnabled:NO];
    [self.navigationItem setRightBarButtonItem:self.btnSave];
    [self.txtPhone setupWithPlaceholderColor:[UIColor appGreyishColor] andFont:[UIFont systemFontOfSize:17 weight:UIFontWeightLight]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
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
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"error")
                                                                            message:OTLocalizedString(@"inviteByPhoneFailed")
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

@end
