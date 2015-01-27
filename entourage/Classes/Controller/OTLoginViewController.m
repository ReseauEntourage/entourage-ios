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

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIView *whiteBackground;

@end

@implementation OTLoginViewController

- (void)viewWillAppear:(BOOL)animated {
	self.whiteBackground.layer.cornerRadius = 5;
	self.whiteBackground.layer.masksToBounds = YES;
}

- (IBAction)validateButtonDidTad:(UIButton *)sender {
	if (self.emailTextField.text.length == 0) {
		[[[UIAlertView alloc]
		  initWithTitle:@"Connexion impossible"
		               message:@"Veuillez renseigner une adresse email"
		              delegate:nil
		     cancelButtonTitle:nil
		     otherButtonTitles:@"ok",
		  nil] show];
	}
	else if (!self.validateForm) {
		[[[UIAlertView alloc]
		  initWithTitle:@"Connexion impossible"
		               message:@"Adresse email invalide"
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
	return [self.emailTextField.text isValidEmail];
}

- (void)launchAuthentication {
	[[OTAuthService new]
	 authWithEmail:self.emailTextField.text

	       success: ^(OTUser *user)
	{
	    NSLog(@"User : %@ authenticated successfully", user.email);
	    [[NSUserDefaults standardUserDefaults] setCurrentUser:user];

	    [self dismissViewControllerAnimated:YES completion:nil];
	}

	 failure: ^(NSError *error)
	{
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
