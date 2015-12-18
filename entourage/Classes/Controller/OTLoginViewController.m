//
//  OTLoginViewController.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTLoginViewController.h"

// Service
#import "OTAuthService.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"

// Model
#import "OTUser.h"

// View
#import "SVProgressHUD.h"

@interface OTLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIView *whiteBackground;
@property (weak, nonatomic) IBOutlet UIButton *askMoreButton;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;

@end

@implementation OTLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
	self.whiteBackground.layer.cornerRadius = 5;
	self.whiteBackground.layer.masksToBounds = YES;
}

- (IBAction)validateButtonDidTad:(UIButton *)sender {
	if (self.phoneTextField.text.length == 0) {
		[[[UIAlertView alloc]
		  initWithTitle:@"Connexion impossible"
		               message:@"Veuillez renseigner un numéro de téléphone"
		              delegate:nil
		     cancelButtonTitle:nil
		     otherButtonTitles:@"ok",
		  nil] show];
	}
	else if (!self.validateForm) {
		[[[UIAlertView alloc]
		  initWithTitle:@"Connexion impossible"
		               message:@"Numéro de téléphone invalide"
		              delegate:nil
		     cancelButtonTitle:nil
		     otherButtonTitles:@"ok",
		  nil] show];
	}
	else {
		[self launchAuthentication];
	}
}

- (BOOL)validateForm {
    return [self.phoneTextField.text isValidPhoneNumber];
}

- (void)launchAuthentication {
    [SVProgressHUD show];
    [[OTAuthService new] authWithPhone:self.phoneTextField.text.phoneNumberServerRepresentation
                              password:self.passwordTextField.text
                              deviceId:[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"]
                               success: ^(OTUser *user) {
                                   NSLog(@"User : %@ authenticated successfully", user.email);
                                   [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
                                   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
                                   [SVProgressHUD dismiss];
                                   [self dismissViewControllerAnimated:YES completion:nil];
                               } failure: ^(NSError *error) {
                                   [SVProgressHUD dismiss];
                                   [[[UIAlertView alloc]
                                     initWithTitle:@"Erreur"
                                     message:@"Echec de la connexion"
                                     delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"ok",
                                     nil] show];
                               }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (IBAction)displayAskMoreModal:(id)sender {
    [self performSegueWithIdentifier:@"OTAskMore" sender:self];
}

@end
