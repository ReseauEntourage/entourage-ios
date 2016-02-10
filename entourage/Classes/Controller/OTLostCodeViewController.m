//
//  OTLostCodeViewController.m
//  entourage
//
//  Created by Nicolas Telera on 05/01/2016.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTLostCodeViewController.h"

// Service
#import "OTAuthService.h"

#import "UIViewController+menu.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UITextField+indentation.h"

// Model
#import "OTUser.h"

// View
#import "SVProgressHUD.h"

/********************************************************************************/
#pragma mark - OTLostCodeViewController

@interface OTLostCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *regenerateCodeButton;
@property (weak, nonatomic) IBOutlet UIView *inputContainerView;
@property (weak, nonatomic) IBOutlet UIView *numberNotFoundContainerView;
@property (weak, nonatomic) IBOutlet UIView *smsContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *actionIcon;

@end

@implementation OTLostCodeViewController

/********************************************************************************/
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"REDEMANDER UN CODE";
    [self setupCloseModal];
    [self.phoneTextField indentRight];
    [self showPhoneInputContainer];
}

#pragma mark - Private
- (void)showPhoneInputContainer {
    [self.phoneTextField becomeFirstResponder];
    self.numberNotFoundContainerView.hidden = YES;
    self.smsContainerView.hidden = YES;

}

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
                                          [SVProgressHUD showSuccessWithStatus:@"Demande effectuée!"];
                                          [self showSMSContainer];
                                      }
                                      failure:^(NSError *error) {
                                          [SVProgressHUD dismiss];
                                          if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"Not Found"]) {
                                              [self showNumberNotFoundContainer];
                                          }
                                          else
                                          {
                                              [[[UIAlertView alloc]
                                                initWithTitle:@"Erreur"
                                                message:@"Echec lors de la demande"
                                                delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"ok",
                                                nil] show];
                                          }
                                      }];
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)regenerateButtonDidTap:(id)sender {
    if (self.phoneTextField.text.length == 0) {
        [[[UIAlertView alloc]
          initWithTitle:@"Demande impossible"
          message:@"Veuillez renseigner un numéro de téléphone"
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"ok",
          nil] show];
    }
    else if (![self.phoneTextField.text isValidPhoneNumber]) {
        [[[UIAlertView alloc]
          initWithTitle:@"Demande impossible"
          message:@"Numéro de téléphone invalide"
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"ok",
          nil] show];
    }
    else {
        [self.phoneTextField setSelected:NO];
        [self regenerateSecretCode];
    }
}

@end
