//
//  OTUserViewController.m
//  entourage
//
//  Created by Nicolas Telera on 17/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTUserViewController.h"

// Controller
#import "UIViewController+menu.h"

// Service
#import "OTAuthService.h"

// Model
#import "OTUser.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"

// View
#import "SVProgressHUD.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTUserViewController ()

@property (nonatomic, strong) OTUser *currentUser;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UILabel *toursLabel;
@property (nonatomic, weak) IBOutlet UILabel *encountersLabel;
@property (nonatomic, weak) IBOutlet UILabel *organizationLabel;

@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *accessCodeField;
@property (nonatomic, weak) IBOutlet UITextField *confirmationField;

@property (nonatomic, weak) IBOutlet UIButton *updateButton;
@property (nonatomic, weak) IBOutlet UIButton *unsubscribeButton;

@property (weak, nonatomic) IBOutlet UISwitch *myToursSwitch;

@end

@implementation OTUserViewController

/********************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createMenuButton];
}

- (void)viewWillAppear:(BOOL)animated {
    self.currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.currentUser firstName], [self.currentUser lastName]];
    if (self.currentUser.email != nil) {
        self.emailLabel.text = self.currentUser.email;
        self.emailField.text = self.currentUser.email;
    }
    self.toursLabel.text = [NSString stringWithFormat:@"%@ maraudes réalisées", [self.currentUser tourCount]];
    self.encountersLabel.text = [NSString stringWithFormat:@"%@ personnes rencontrées", [self.currentUser encounterCount]];
    self.organizationLabel.text = self.currentUser.organization.name;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"user_tours_only"]) {
        [self.myToursSwitch setOn:YES];
    } else {
        [self.myToursSwitch setOn:NO];
    }
    self.title = NSLocalizedString(@"userviewcontroller_title", @"");
}

/********************************************************************************/
#pragma mark - Private methods

- (BOOL)validateForm {
    return (![self.emailField.text isEqualToString:@""] &&
            ![self.accessCodeField.text isEqualToString:@""] &&
            ![self.confirmationField.text isEqualToString:@""] &&
            [self.emailField.text isValidEmail] &&
            [self.accessCodeField.text isNumeric] &&
            [self.confirmationField.text isNumeric] &&
            [self.accessCodeField.text isEqualToString:self.confirmationField.text]);
}

- (void)emptyForm {
    self.accessCodeField.text = @"";
    self.confirmationField.text = @"";
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)displayUserToursOnly:(id)sender {
    if ([self.myToursSwitch isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"user_tours_only"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
    }
}

- (IBAction)updateUserInformation:(id)sender {
    if (self.validateForm) {
        [SVProgressHUD show];
        [[OTAuthService new] updateUserInformationWithEmail:self.emailField.text
                                                 andSmsCode:self.accessCodeField.text
                                                    success:^(NSString *email) {
                                                        [SVProgressHUD showSuccessWithStatus:@"Informations mises à jour"];
                                                        self.currentUser.email = email;
                                                        [[NSUserDefaults standardUserDefaults] setCurrentUser:self.currentUser];
                                                        self.emailLabel.text = email;
                                                        self.emailField.text = email;
                                                        [self emptyForm];
                                                    } failure:^(NSError *error) {
                                                        [SVProgressHUD showSuccessWithStatus:@"Informations non mises à jour"];
                                                    } ];
    }
}

- (IBAction)unsubscribe:(id)sender {
    
}

@end
