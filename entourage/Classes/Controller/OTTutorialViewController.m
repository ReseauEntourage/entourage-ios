//
//  OTTutorialViewController.m
//  entourage
//
//  Created by Nicolas Telera on 06/01/2016.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTutorialViewController.h"

// Controller
#import "OTLoginViewController.h"

// Service
#import "OTAuthService.h"

// Util
#import "UIStoryboard+entourage.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"

// Model
#import "OTUser.h"

// View
#import "SVProgressHUD.h"

/********************************************************************************/
#pragma mark - OTTutorialViewController

@interface OTTutorialViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *emailScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *tutorialScrollView;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *validateEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *finishTutorialButton;

@property (nonatomic, strong) NSString *phoneNumberServerRepresentation;

@end

@implementation OTTutorialViewController

/********************************************************************************/
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"";
    if (![[[NSUserDefaults standardUserDefaults] currentUser].email isEqualToString:@""]) {
        self.emailTextField.text = [[NSUserDefaults standardUserDefaults] currentUser].email;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

/********************************************************************************/
#pragma mark - Public Methods

- (void)configureWithPhoneNumber:(NSString *)phoneNumber {
    self.phoneNumberServerRepresentation = phoneNumber;
}

- (void)displayTutorial {
    [self.emailScrollView setHidden:YES];
    [self.tutorialScrollView setHidden:NO];
}

- (void)updateUserEmail {
    [[OTAuthService new] updateUserInformationWithEmail:self.emailTextField.text
                                             andSmsCode:nil
                                                success:^(NSString *email) {
                                                    [SVProgressHUD dismiss];
                                                    //[SVProgressHUD showSuccessWithStatus:@"Adresse email mise à jour !"];
                                                    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
                                                    currentUser.email = email;
                                                    [[NSUserDefaults standardUserDefaults] setCurrentUser:currentUser];
                                                    
                                                    //TODO: remove this when the tutorial content is ready
                                                    NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
                                                    if (loggedNumbers == nil) {
                                                        loggedNumbers = [NSMutableArray new];
                                                    }
                                                    [loggedNumbers addObject:self.phoneNumberServerRepresentation];
                                                    [[NSUserDefaults standardUserDefaults] setObject:loggedNumbers forKey:kTutorialDone];
                                                    //[UIStoryboard showSWRevealController];
                                                    [self performSegueWithIdentifier:@"RightsSegue" sender:nil];
                                                    //TODO: put this back when the tutorial content is ready
                                                    //[self displayTutorial];
                                                } failure:^(NSError *error) {
                                                    [SVProgressHUD dismiss];
                                                    [[[UIAlertView alloc]
                                                      initWithTitle:@"Erreur"
                                                      message:@"Echec de la mise à jour de l'email"
                                                      delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"ok",
                                                      nil] show];
                                                }];
    
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)updateEmailDidTap:(id)sender {
    if (self.emailTextField.text.length == 0) {
        [[[UIAlertView alloc]
          initWithTitle:@"Validation impossible"
          message:@"Veuillez renseigner une adresse email"
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"ok",
          nil] show];
    }
    else if (![self.emailTextField.text isValidEmail]) {
        [[[UIAlertView alloc]
          initWithTitle:@"Validation impossible"
          message:@"Adresse email invalide"
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"ok",
          nil] show];
    }
    else {
        [SVProgressHUD show];
        [self updateUserEmail];
    }
}

- (IBAction)finishTutorial:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"has_done_tutorial"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
