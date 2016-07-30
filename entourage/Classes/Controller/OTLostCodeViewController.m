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

#import "UIViewController+menu.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UITextField+indentation.h"
#import "UINavigationController+entourage.h"
#import "UIView+entourage.h"
#import "UIScrollView+entourage.h"
#import "UIColor+entourage.h"

// Model
#import "OTUser.h"

// View
#import "SVProgressHUD.h"

/********************************************************************************/
#pragma mark - OTLostCodeViewController

@interface OTLostCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *regenerateCodeButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *inputContainerView;
@property (weak, nonatomic) IBOutlet UIView *numberNotFoundContainerView;
@property (weak, nonatomic) IBOutlet UIView *smsContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *actionIcon;
@property (weak, nonatomic) IBOutlet UITextField *smsTextField;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation OTLostCodeViewController

/********************************************************************************/
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"";
    [self setupCloseModalTransparent];
    [self.phoneTextField indentRight];
    //[self showPhoneInput];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.navigationController presentTransparentNavigationBar];
    
    [self.regenerateCodeButton setupHalfRoundedCorners];
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
#if DEBUG
    self.phoneTextField.text = @"+40724593579";
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.phoneTextField becomeFirstResponder];
}

#pragma mark - Private


- (void)showNumberNotFoundContainer {
    [self.phoneTextField resignFirstResponder];
    self.inputContainerView.hidden = YES;
    self.numberNotFoundContainerView.hidden = NO;
    self.smsContainerView.hidden = YES;
    self.actionIcon.image = [UIImage imageNamed:@"phone"];
}

- (void)showSMSContainer {
    [self.phoneTextField resignFirstResponder];
    
    self.inputContainerView.hidden = YES;
    self.numberNotFoundContainerView.hidden = YES;
    self.smsContainerView.hidden = NO;
    self.actionIcon.image = [UIImage imageNamed:@"sms"];
}

/********************************************************************************/
#pragma mark - Public Methods

- (void)regenerateSecretCode {
    [SVProgressHUD show];
    [[OTAuthService new] regenerateSecretCode:self.phoneTextField.text.phoneNumberServerRepresentation
                                      success:^(OTUser *user) {
                                          [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"requestSent")];
                                          [self showSMSContainer];
                                      }
                                      failure:^(NSError *error) {
                                          [SVProgressHUD dismiss];
                                          if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Not Found"]) {
                                              [self showNumberNotFoundContainer];
                                              //test SMS without really resetting code
                                              //[self showSMSContainer];
                                          }
                                          else
                                          {
                                              [[[UIAlertView alloc]
                                                initWithTitle:OTLocalizedString(@"error") //@"Erreur"
                                                message:OTLocalizedString(@"requestNotSent")// @"Echec lors de la demande"
                                                delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Ok",
                                                nil] show];
                                          }
                                      }];
}

/********************************************************************************/
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

- (IBAction)sendSMSButtonDidTap:(id)sender {

    if (self.smsTextField.text.length == 0) {
        [[[UIAlertView alloc]
          initWithTitle:OTLocalizedString(@"requestImposible")
          message:OTLocalizedString(@"mustAddCode")
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
          nil] show];
    }
    else if (![self.smsTextField.text isValidCode]) {
        [[[UIAlertView alloc]
          initWithTitle:OTLocalizedString(@"requestImposible")
          message:OTLocalizedString(@"invalidCode")
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
          nil] show];
    }
    else {
        if ([self.codeDelegate respondsToSelector:@selector(loginWithNewCode:)]) {
            //[self dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"New code: %@", self.smsTextField.text);
            [self.codeDelegate loginWithNewCode:self.smsTextField.text];
        }
        
    }
}

- (IBAction)showPhoneInput {
    [self.phoneTextField becomeFirstResponder];
    self.inputContainerView.hidden = NO;
    self.numberNotFoundContainerView.hidden = YES;
    self.smsContainerView.hidden = YES;
    self.actionIcon.image = [UIImage imageNamed:@"phone"];
}

- (void)showKeyboard:(NSNotification*)notification {
    //[self.scrollView scrollToBottomFromKeyboardNotification:notification];
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint];
    
}


@end
