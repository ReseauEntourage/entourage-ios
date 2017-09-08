//
//  OTLostCodeViewController.m
//  entourage
//
//  Created by Nicolas Telera on 05/01/2016.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTLostCodeViewController.h"
#import "OTConsts.h"
#import "OTAuthService.h"
#import "IQKeyboardManager.h"
#import "OTScrollPinBehavior.h"
#import "UIViewController+menu.h"
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UITextField+indentation.h"
#import "UINavigationController+entourage.h"
#import "UIView+entourage.h"
#import "UIColor+entourage.h"
#import "OTUser.h"
#import "SVProgressHUD.h"
#import "NSError+OTErrorData.h"
#import "OTCountryCodePickerViewDataSource.h"
#import "JVFloatLabeledTextField.h"

@interface OTLostCodeViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet OTScrollPinBehavior *scrollBehavior;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet JVFloatLabeledTextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;

@property (weak, nonatomic) OTCountryCodePickerViewDataSource *pickerDataSource;
@property (weak, nonatomic) NSString *codeCountry;

@end

@implementation OTLostCodeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.scrollBehavior initialize];

    self.navigationController.navigationBarHidden = NO;
    self.title = @"";
    [self setupCloseModalTransparent];
    [self.phoneTextField indentRight];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.navigationController presentTransparentNavigationBar];
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.countryCodeTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    self.countryCodeTextField.keepBaseline = YES;
    self.countryCodeTextField.floatingLabelTextColor = [UIColor clearColor];
    self.countryCodeTextField.floatingLabelActiveTextColor = [UIColor clearColor];
    self.pickerDataSource = [OTCountryCodePickerViewDataSource sharedInstance];
}

- (void)viewDidAppear:(BOOL)animated {
    [IQKeyboardManager sharedManager].enable = NO;
    [super viewDidAppear:animated];
    self.countryCodeTextField.inputView = self.pickerView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

#pragma mark - Public Methods

- (void)regenerateSecretCode {
    [SVProgressHUD show];
    NSString *phoneNumber = self.phoneTextField.text;
    if([self.phoneTextField.text hasPrefix:@"0"])
        phoneNumber = [self.phoneTextField.text substringFromIndex:1];
    NSString *phone = [self.codeCountry stringByAppendingString:phoneNumber];
    [[OTAuthService new] regenerateSecretCode:phone success:^(OTUser *user) {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"requestSent")];
    }
    failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSString *alertTitle = OTLocalizedString(@"error");
        NSString *alertMessage = OTLocalizedString(@"requestNotSent");
        NSString *status = [error readErrorStatus];
        if ([status isEqualToString:@"404"]) {
            alertTitle = @"";
            alertMessage = OTLocalizedString(@"lost_code_phone_does_not_exist");
        }
        [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:OTLocalizedString(@"tryAgain_short"), nil] show];
    }];
}

#pragma mark - Actions

- (IBAction)regenerateButtonDidTap:(id)sender {
    NSString *phone = [self.codeCountry stringByAppendingString:self.phoneTextField.text];
    if (phone.length == 0) {
        [[[UIAlertView alloc]
          initWithTitle: OTLocalizedString(@"requestImposible")
          message:OTLocalizedString(@"retryPhone")
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
          nil] show];
    }
    else if (![phone isValidPhoneNumber]) {
        [[[UIAlertView alloc]
          initWithTitle:OTLocalizedString(@"requestImposible")
          message:OTLocalizedString(@"invalidPhoneNumber")//@"Numéro de téléphone invalide"
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
          nil] show];
    }
    else {
        [self.phoneTextField setSelected:NO];
        [self regenerateSecretCode];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerDataSource count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerDataSource getTitleForRow:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.countryCodeTextField.text = [self.pickerDataSource getCountryShortNameForRow:row];
    self.codeCountry = [self.pickerDataSource getCountryCodeForRow:row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.pickerDataSource getTitleForRow:row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}

@end
