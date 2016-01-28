//
//  OTLoginViewController.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTLoginViewController.h"

// Controller
#import "OTLostCodeViewController.h"
#import "OTTutorialViewController.h"

// Service
#import "OTAuthService.h"

// Utils
#import "UITextField+indentation.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UINavigationController+entourage.h"

// Model
#import "OTUser.h"

// View
#import "SVProgressHUD.h"

/********************************************************************************/
#pragma mark - Constants
NSString *const kTutorialDone = @"has_done_tutorial";

/********************************************************************************/
#pragma mark - OTLoginViewController

@interface OTLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurEffect;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIView *whiteBackground;
@property (weak, nonatomic) IBOutlet UIButton *askMoreButton;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
@property (weak, nonatomic) IBOutlet UIButton *lostCodeButton;

@property (nonatomic, strong) NSString *phoneNumberServerRepresentation;

@end

@implementation OTLoginViewController

/********************************************************************************/
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //self.navigationController.navigationBarHidden = NO;
//    UINavigationBar.appearance.barTintColor = [UIColor redColor];
//    UINavigationBar.appearance.backgroundColor = [UIColor clearColor];
    [self.navigationController presentTransparentNavigationBar];

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
	self.whiteBackground.layer.cornerRadius = 5;
	self.whiteBackground.layer.masksToBounds = YES;
    
    [self.phoneTextField indentRight];
    [self.passwordTextField indentRight];
    
    [self.phoneTextField becomeFirstResponder];
    
#if DEBUG
    self.phoneTextField.text = @"0651502173";
    self.passwordTextField.text = @"123456";
#endif
    
}

- (void)viewWillDisappear:(BOOL)animated {
    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
    UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];
}

/********************************************************************************/
#pragma mark - Public Methods

- (BOOL)validateForm {
    return [self.phoneTextField.text isValidPhoneNumber];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)launchAuthentication {
    [SVProgressHUD show];
    self.phoneNumberServerRepresentation = self.phoneTextField.text.phoneNumberServerRepresentation;
    [[OTAuthService new] authWithPhone:self.phoneNumberServerRepresentation
                              password:self.passwordTextField.text
                              deviceId:[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"]
                               success: ^(OTUser *user) {
                                   NSLog(@"User : %@ authenticated successfully", user.email);
                                   [SVProgressHUD dismiss];
                                   [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
                                   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
                                   
                                   // new way
#warning @Nicholas: arrayWithArray crashes the app. changed to arrayWithObject
                                   NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
                                   if (loggedNumbers == nil) {
                                       loggedNumbers = [NSMutableArray new];
                                   }
                                   if ([loggedNumbers containsObject:self.phoneNumberServerRepresentation]) {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   } else {
                                       [self performSegueWithIdentifier:@"OTTutorial" sender:self];
                                   }
                                   
                                   
                                   
                                   // old way
                                   /*
                                   if ([[NSUserDefaults standardUserDefaults] boolForKey:@"has_done_tutorial"]) {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   } else {
                                       [self performSegueWithIdentifier:@"OTTutorial" sender:self];
                                   }
                                    */
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

/********************************************************************************/
#pragma mark - OTAskMoreViewControllerDelegate

- (void)hideBlurEffect {
    [UIView animateWithDuration:0.5 animations:^(void) {
        [self.blurEffect setAlpha:0.0];
    }];
}

/********************************************************************************/
#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OTAskMore"]) {
        OTAskMoreViewController *controller = (OTAskMoreViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"OTTutorial"]) {
        OTTutorialViewController *controller = (OTTutorialViewController *)segue.destinationViewController;
        [controller configureWithPhoneNumber:self.phoneNumberServerRepresentation];
    }
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)displayAskMoreModal:(id)sender {
    [self.blurEffect setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^(void) {
        [self.blurEffect setAlpha:0.7];
    }];
    [self performSegueWithIdentifier:@"OTAskMore" sender:self];
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

@end
