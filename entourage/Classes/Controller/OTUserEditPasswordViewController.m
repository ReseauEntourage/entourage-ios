//
//  OTUserEditPasswordViewController.m
//  entourage
//
//  Created by Mihai Ionescu on 08/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

// Controllers
#import "OTUserEditPasswordViewController.h"
#import "UIViewController+menu.h"

// Services
#import "OTAuthService.h"

// Helpers
#import "A0SimpleKeychain.h"

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
    // Do any additional setup after loading the view.
    [self setupCloseModal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)doValidate:(id)sender {
    NSString *currentPassword = self.currentPasswordTextField.text;
    NSString *newPassword = self.passwordTextField.text;
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    //check if the current password matches
    NSString *savedPassword = [[A0SimpleKeychain keychain] stringForKey:kKeychainPassword];
    if (![savedPassword isEqualToString:currentPassword]) {
        [self showDialogWithMessage:NSLocalizedString(@"user_edit_password_invalid_current", @"")
                         setFocusAt:self.currentPasswordTextField];
        return;
    }
    //check for minimum length
    if (newPassword.length < MIN_PASSWORD_LENGTH) {
        [self showDialogWithMessage:[NSString stringWithFormat:NSLocalizedString(@"user_edit_password_invalid_length_too_short", @""), MIN_PASSWORD_LENGTH]
                         setFocusAt:self.passwordTextField];
        return;
    }
    //check for maximum length
    if (newPassword.length > MAX_PASSWORD_LENGTH) {
        [self showDialogWithMessage:[NSString stringWithFormat:NSLocalizedString(@"user_edit_password_invalid_length_too_long", @""), MAX_PASSWORD_LENGTH]
                         setFocusAt:self.passwordTextField];
        return;
    }
    //check if the new and confirm password match
    if (![newPassword isEqualToString:confirmPassword]) {
        [self showDialogWithMessage:NSLocalizedString(@"user_edit_password_invalid_match", @"")
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
