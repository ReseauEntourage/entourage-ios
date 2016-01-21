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

@end

@implementation OTLostCodeViewController

/********************************************************************************/
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [self.phoneTextField indentRight];
    [self.phoneTextField becomeFirstResponder];
}

/********************************************************************************/
#pragma mark - Public Methods

- (void)regenerateSecretCode {
    [SVProgressHUD show];
    [[OTAuthService new] regenerateSecretCode:self.phoneTextField.text.phoneNumberServerRepresentation
                                      success:^(OTUser *user) {
                                              [SVProgressHUD showSuccessWithStatus:@"Demande effectuée !"];
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                      } failure:^(NSError *error) {
                                          [SVProgressHUD dismiss];
                                          [[[UIAlertView alloc]
                                            initWithTitle:@"Erreur"
                                            message:@"Echec lors de la demande"
                                            delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"ok",
                                            nil] show];
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
