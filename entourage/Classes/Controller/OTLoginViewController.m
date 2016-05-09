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
#import "OTJSONResponseSerializer.h"

// Utils
#import "UITextField+indentation.h"
#import "UIStoryboard+entourage.h"

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

@interface OTLoginViewController () <UITextFieldDelegate, LostCodeDelegate>

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
    [self.navigationController presentTransparentNavigationBar];

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
	self.whiteBackground.layer.cornerRadius = 5;
	self.whiteBackground.layer.masksToBounds = YES;
    
    [self.phoneTextField indentRight];
    [self.passwordTextField indentRight];
    
    [self.phoneTextField becomeFirstResponder];
    
//#if DEBUG
//    // Ciprian
//    self.phoneTextField.text = @"+40740884267";
   // self.phoneTextField.text = @"+40740884267";
//    self.passwordTextField.text = @"600533";
//    
////    //Vincent
////    self.phoneTextField.text = @"0651502173";
////    self.passwordTextField.text = @"123456";
////
////    // Ciprian + Mihai
////    self.phoneTextField.text = @"0623456789";
////    self.passwordTextField.text = @"123456";
////
//    // Vasile QA
//    self.phoneTextField.text = @"+40723199641";
//    //self.passwordTextField.text = @"123456";
//    
//    
//    // Vincent PRO
//    //self.phoneTextField.text = @"+33651502173";
   // self.passwordTextField.text = @"123456";
//#endif
    
}

- (void)viewWillDisappear:(BOOL)animated {
    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
    UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];
    self.title = @"";
}

/********************************************************************************/
#pragma mark - Public Methods

- (BOOL)validateForm {
#if DEBUG
    return YES;
#else
    return [self.phoneTextField.text isValidPhoneNumber];
#endif
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
                                   user.phone = self.phoneNumberServerRepresentation;
                                   [SVProgressHUD dismiss];
                                   [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
                                   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   
                                   NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
                                   if (loggedNumbers == nil) {
                                       loggedNumbers = [NSMutableArray new];
                                   }
                                   if ([loggedNumbers containsObject:self.phoneNumberServerRepresentation]) {
                                       [UIStoryboard showSWRevealController];
                                   } else {
                                       [self performSegueWithIdentifier:@"OTTutorial" sender:self];
                                   }
                               } failure: ^(NSError *error) {
                                   [SVProgressHUD dismiss];
                                   NSString *alertTitle = @"Erreur";
                                   NSString *alertText = @"Echec de la connexion";
                                   NSString *buttonTitle = @"ok";
                                   if ([[error.userInfo valueForKey:JSONResponseSerializerWithDataKey] isEqualToString:@"unauthorized"]) {
                                       alertTitle = @"Veuillez réessayer";
                                       alertText = @"Le numéro de téléphone et ce code d’accès ne correspondent pas.";
                                       buttonTitle = @"Réessayer";

                                   }
                                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                                  message:alertText
                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                   UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:buttonTitle
                                                                                           style:UIAlertActionStyleDefault
                                                                                         handler:^(UIAlertAction * _Nonnull action) {}];
                                   [alert addAction: defaultAction];
                                   [self presentViewController:alert animated:YES completion:nil];
                                   
                               }];
}

/********************************************************************************/
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.phoneTextField) {
        textField.text = [textField.text phoneNumberServerRepresentation];
    }
    return YES;
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
    } else if ([segue.identifier isEqualToString:@"OTLostCode"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTLostCodeViewController *controller = (OTLostCodeViewController *)navController.viewControllers.firstObject;
        controller.codeDelegate = self;
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

- (IBAction)validateButtonDidTad {
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

/********************************************************************************/
#pragma mark - LostCodeDelegate

- (void)loginWithNewCode:(NSString *)code {
    [self dismissViewControllerAnimated:YES completion:^() {
        self.passwordTextField.text = code;
        [self validateButtonDidTad];
    }];
}


@end
