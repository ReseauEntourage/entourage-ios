//
//  OTUserViewController.m
//  entourage
//
//  Created by Nicolas Telera on 17/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTUserViewController.h"

// Service
#import "OTAuthService.h"

// Model
#import "OTUser.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"

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

@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *updateButton;
@property (nonatomic, weak) IBOutlet UIButton *unsubscribeButton;

@end

@implementation OTUserViewController

/********************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    self.currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.currentUser firstName], [self.currentUser lastName]];
    self.emailLabel.text = self.currentUser.email;
    self.toursLabel.text = [NSString stringWithFormat:@"%@ maraudes réalisées", [self.currentUser tourCount]];
    self.encountersLabel.text = [NSString stringWithFormat:@"%@ personnes rencontrées", [self.currentUser encounterCount]];
    self.organizationLabel.text = self.currentUser.organization.name;
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
    self.emailField.text = @"";
    self.accessCodeField.text = @"";
    self.confirmationField.text = @"";
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)closeProfile:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateUserInformation:(id)sender {
    if (self.validateForm) {
        [[OTAuthService new] updateUserInformationWithEmail:self.emailField.text
                                                 andSmsCode:self.accessCodeField.text
                                                    success:^(NSString *email) {
                                                        self.currentUser.email = email;
                                                        [[NSUserDefaults standardUserDefaults] setCurrentUser:self.currentUser];
                                                        self.emailLabel.text = email;
                                                        [self emptyForm];
                                                    } failure:^(NSError *error) {
                                                    } ];
    }
}

- (IBAction)unsubscribe:(id)sender {
    
}

@end
