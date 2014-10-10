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

@interface OTLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;

@end

@implementation OTLoginViewController

- (void)viewDidLoad {
	if ([[NSUserDefaults new] userMail]) {
		[self performSegueWithIdentifier:@"login_success" sender:self];
	}
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

	       success: ^(NSString *email)
	{
	    NSLog(@"User : %@ authenticated successfully", email);

	    [[NSUserDefaults new] setUserMail:email];
	    [self performSegueWithIdentifier:@"login_success" sender:self];
	    //[self.navigationController popViewControllerAnimated:NO];
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

@end
