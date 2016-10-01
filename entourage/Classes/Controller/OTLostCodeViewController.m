//
//  OTLostCodeViewController.m
//  entourage
//
//  Created by Nicolas Telera on 05/01/2016.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTLostCodeViewController.h"

#import "OTConsts.h"
// Service
#import "OTAuthService.h"
#import "IQKeyboardManager.h"
#import "OTScrollPinBehavior.h"
#import "UIViewController+menu.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UITextField+indentation.h"
#import "UINavigationController+entourage.h"
#import "UIView+entourage.h"
#import "UIColor+entourage.h"

// Model
#import "OTUser.h"

// View
#import "SVProgressHUD.h"

/********************************************************************************/
#pragma mark - OTLostCodeViewController

@interface OTLostCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet OTScrollPinBehavior *scrollBehavior;

@end

@implementation OTLostCodeViewController

/********************************************************************************/
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.scrollBehavior initialize];
    
    self.navigationController.navigationBarHidden = NO;
    self.title = @"";
    [self setupCloseModalTransparent];
    [self.phoneTextField indentRight];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.navigationController presentTransparentNavigationBar];
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [IQKeyboardManager sharedManager].enable = NO;
    [super viewDidAppear:animated];
    [self.phoneTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [IQKeyboardManager sharedManager].enable = YES;
}

#pragma mark - Public Methods

- (void)regenerateSecretCode {
    [SVProgressHUD show];
    [[OTAuthService new] regenerateSecretCode:self.phoneTextField.text success:^(OTUser *user) {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"requestSent")];
    }
    failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc] initWithTitle:OTLocalizedString(@"error") message:OTLocalizedString(@"requestNotSent") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }];
}

#pragma mark - Actions

- (IBAction)regenerateButtonDidTap:(id)sender {
    if (self.phoneTextField.text.length == 0) {
        [[[UIAlertView alloc]
          initWithTitle: OTLocalizedString(@"requestImposible")
          message:OTLocalizedString(@"retryPhone")
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
          nil] show];
    }
    else if (![self.phoneTextField.text isValidPhoneNumber]) {
        [[[UIAlertView alloc]
          initWithTitle:OTLocalizedString(@"requestImposible")
          message:OTLocalizedString(@"invalidPhoneNumber")//@"Numéro de téléphone invalide"
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
          nil] show];
    }
    else {
        [self.phoneTextField setSelected:NO];
        [self regenerateSecretCode];
    }
}

@end
