//
//  OTLostCodeViewController.m
//  entourage
//
//  Created by Nicolas Telera on 05/01/2016.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

#import "OTLostCodeViewController.h"
#import "OTConsts.h"
#import "OTAuthService.h"
#import "OTScrollPinBehavior.h"
#import "UIViewController+menu.h"
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UITextField+indentation.h"
#import "UINavigationController+entourage.h"
#import "UIView+entourage.h"
#import "UIColor+entourage.h"
#import "OTUser.h"
#import "NSError+OTErrorData.h"
#import "OTCountryCodePickerViewDataSource.h"
#import "OTCodeViewController.h"
#import "entourage-Swift.h"

@interface OTLostCodeViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet OTScrollPinBehavior *scrollBehavior;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (weak, nonatomic) OTCountryCodePickerViewDataSource *pickerDataSource;

@end

@implementation OTLostCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.countryCodeTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    self.countryCodeTextField.keepBaseline = YES;
    self.countryCodeTextField.floatingLabelTextColor = [UIColor clearColor];
    self.countryCodeTextField.floatingLabelActiveTextColor = [UIColor clearColor];
    self.codeCountry = @"+33";
    self.countryPicker.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    [self.continueButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    self.phoneTextField.textContentType = UITextContentTypeTelephoneNumber;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    if(self.rowCode)
        [self.countryPicker selectRow:self.rowCode inComponent:0 animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.phoneTextField becomeFirstResponder];
    self.countryCodeTextField.inputView = self.pickerView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

#pragma mark - Public Methods

- (void)regenerateSecretCode {
    [SVProgressHUD show];
    NSString *phoneNumber = [self.phoneTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if(![phoneNumber hasPrefix:@"+"]) {
        if([phoneNumber hasPrefix:@"0"])
            phoneNumber = [phoneNumber substringFromIndex:1];
        phoneNumber = [self.codeCountry stringByAppendingString:phoneNumber];
    }
    [[OTAuthService new] regenerateSecretCode:phoneNumber
                                      success:^(OTUser *user)
    {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"requestSent")];
        [self continueOnSuccess:user phone:phoneNumber];
    }
    failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSString *alertTitle = OTLocalizedString(@"error");
        NSString *alertMessage = OTLocalizedString(@"requestNotSent");
        NSString *status = [error readErrorStatus];
        
        if ([status isEqualToString:@"404"]) {
            alertTitle = @"";
            alertMessage = [OTAppAppearance userPhoneNumberNotFoundMessage];
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OTLocalizedString(@"tryAgain_short") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)continueOnSuccess:(OTUser*)user phone:(NSString*)phone {
//    if (self.codeDelegate != nil && [self.codeDelegate respondsToSelector:@selector(loginWithCountryCode:andPhoneNumber:)]) {
//        [self.codeDelegate loginWithCountryCode:[self.countryPicker selectedRowInComponent:0]
//                                 andPhoneNumber:self.phoneTextField.text];
//    }
    
    
    user.phone = phone;
    [NSUserDefaults standardUserDefaults].temporaryUser = user;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:nil];
    OTCodeViewController *codeViewController = (OTCodeViewController*)[storyboard instantiateViewControllerWithIdentifier:@"OTCodeViewController"];
    [self.navigationController pushViewController:codeViewController animated:YES];
}

#pragma mark - Actions

- (IBAction)regenerateButtonDidTap:(id)sender {
    NSString *phoneNumber = [self.phoneTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if(![phoneNumber hasPrefix:@"+"]) {
        if([phoneNumber hasPrefix:@"0"])
            phoneNumber = [phoneNumber substringFromIndex:1];
        phoneNumber = [self.codeCountry stringByAppendingString:phoneNumber];
    }
    if (phoneNumber.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"requestImposible")
                                                                                 message:OTLocalizedString(@"retryPhone") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (![phoneNumber isValidPhoneNumber]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"requestImposible")
                                                                                 message:OTLocalizedString(@"invalidPhoneNumber") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
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

-(NSString *)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row
           forComponent:(NSInteger)component {
    return [self.pickerDataSource getTitleForRow:row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    self.countryCodeTextField.text = [self.pickerDataSource getCountryShortNameForRow:row];
    self.codeCountry = [self.pickerDataSource getCountryCodeForRow:row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component {
    NSString *title = [self.pickerDataSource getTitleForRow:row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title
                                    attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}

@end
