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

// SoundCloud API
#import "SCSoundCloud.h"

// Model
#import "OTUser.h"

@interface OTLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIView *whiteBackground;

@end

@implementation OTLoginViewController

- (void)viewWillAppear:(BOOL)animated {
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
    [[OTAuthService new] authWithPhone:self.phoneTextField.text.phoneNumberServerRepresentation
                              password:self.passwordTextField.text
                              deviceId:@"test"
                               success: ^(OTUser *user) {
                                   NSLog(@"User : %@ authenticated successfully", user.email);
                                   [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
                                   
                                   [self dismissViewControllerAnimated:YES completion:nil];
                               } failure: ^(NSError *error) {
                                   [[[UIAlertView alloc]
                                     initWithTitle:@"error"
                                     message:error.localizedDescription
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

@end
