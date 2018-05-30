//
//  OTUserEditPasswordViewController.m
//  entourage
//
//  Created by Mihai Ionescu on 08/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTUserEditPasswordViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"
#import "OTAuthService.h"
#import "A0SimpleKeychain.h"
#import "UIColor+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "entourage-Swift.h"

#define MIN_PASSWORD_LENGTH 6
#define MAX_PASSWORD_LENGTH 6

@interface OTUserEditPasswordViewController ()

@property (nonatomic, weak) IBOutlet UITextField *currentPasswordTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation OTUserEditPasswordViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupToolbarButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTLogger logEvent:@"Screen09_4EditPasswordView"];
}

- (void)setupToolbarButtons {
    [self setupCloseModalWithTintColor];

    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"save").capitalizedString
                                                        withTarget:self
                                                         andAction:@selector(doValidate:)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[ApplicationTheme shared].secondaryNavigationBarTintColor];
    [self.navigationItem setRightBarButtonItem:menuButton];
}

#pragma mark - IBActions

- (IBAction)doValidate:(id)sender {
    [OTLogger logEvent:@"Screen09_4ChangePasswordSubmit"];
    NSString *currentPassword = self.currentPasswordTextField.text;
    NSString *newPassword = self.passwordTextField.text;
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    //check if the current password matches
    NSString *savedPassword = [[A0SimpleKeychain keychain] stringForKey:kKeychainPassword];
    if (![savedPassword isEqualToString:currentPassword]) {
        [self showDialogWithMessage:OTLocalizedString(@"user_edit_password_invalid_current")
                         setFocusAt:self.currentPasswordTextField];
        return;
    }
    //check for minimum length
    if (newPassword.length < MIN_PASSWORD_LENGTH) {
        [self showDialogWithMessage:[NSString stringWithFormat:OTLocalizedString(@"user_edit_password_invalid_length_too_short"), MIN_PASSWORD_LENGTH]
                         setFocusAt:self.passwordTextField];
        return;
    }
    //check for maximum length
    if (newPassword.length > MAX_PASSWORD_LENGTH) {
        [self showDialogWithMessage:[NSString stringWithFormat:OTLocalizedString(@"user_edit_password_invalid_length_too_long"), MAX_PASSWORD_LENGTH]
                         setFocusAt:self.passwordTextField];
        return;
    }
    //check if the new and confirm password match
    if (![newPassword isEqualToString:confirmPassword]) {
        [self showDialogWithMessage:OTLocalizedString(@"user_edit_password_invalid_match")
                         setFocusAt:self.confirmPasswordTextField];
        return;
    }
    //inform the delegate
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(setNewPassword:)]) {
        [self.delegate setNewPassword:newPassword];
    }
}

#pragma mark - Private methods

- (void)showDialogWithMessage:(NSString *)message
                   setFocusAt:(UITextField *)focusTextField
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [focusTextField becomeFirstResponder];
                                                          }];
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
