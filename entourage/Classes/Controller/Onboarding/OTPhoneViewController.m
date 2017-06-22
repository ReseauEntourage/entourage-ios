//
//  OTPhoneViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 06/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPhoneViewController.h"
#import "IQKeyboardManager.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "UIScrollView+entourage.h"
#import "UIColor+entourage.h"
#import "NSError+OTErrorData.h"
#import "OTConsts.h"
#import "OTDeepLinkService.h"
#import "entourage-Swift.h"
#import "OTCountryCodePickerViewDataSource.h"

@interface OTPhoneViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet OnBoardingNumberTextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, weak) IBOutlet OnBoardingButton *validateButton;
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTxtField;
@property (weak, nonatomic) IBOutlet UIPickerView *countryCodePicker;

@property (nonatomic, strong) NSArray *array;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) NSString *codeCountry;
@property (weak, nonatomic) NSDictionary *pickerSourceDictionary;

@end

@implementation OTPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";

    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    self.phoneTextField.inputValidationChanged = ^(BOOL isValid) {
        self.validateButton.enabled = isValid;
    };
    self.countryCodePicker.dataSource = self;
    self.countryCodePicker.delegate = self;
    self.countryCodeTxtField.delegate = self;
    self.phoneTextField.delegate = self;
    self.pickerSourceDictionary = [OTCountryCodePickerViewDataSource getConstDictionary];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.countryCodeTxtField.inputView = self.pickerView;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 10;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"TelephoneSubmit"];
    OTUser *temporaryUser = [OTUser new];
    NSString *phone = [self.codeCountry stringByAppendingString:self.phoneTextField.text];
    [self.codeCountry stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temporaryUser.phone = phone;

    [SVProgressHUD show];
    [[OTOnboardingService new] setupNewUserWithPhone:phone
        success:^(OTUser *onboardUser) {
            [SVProgressHUD dismiss];
            onboardUser.phone = phone;
            [NSUserDefaults standardUserDefaults].temporaryUser = onboardUser;
            [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSString *errorMessage = error.localizedDescription;
            NSString *errorCode = [error readErrorCode];
            BOOL showErrorHUD = YES;
            if([errorCode isEqualToString:INVALID_PHONE_FORMAT]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:OTLocalizedString(@"invalidPhoneNumberFormat") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"close") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:defaultAction];
                UIAlertAction *openLoginAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"already_subscribed") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[OTDeepLinkService new] navigateToLogin];
                }];
                [alert addAction:openLoginAction];
                [self presentViewController:alert animated:YES completion:nil];
                showErrorHUD = NO;
            }
            else if([errorCode isEqualToString:PHONE_ALREADY_EXIST]) {
                [NSUserDefaults standardUserDefaults].temporaryUser = temporaryUser;
                [SVProgressHUD dismiss];
                [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
                errorMessage = OTLocalizedString(@"alreadyRegisteredShortMessage");
            }
            if (errorMessage) {
                [OTLogger logEvent:@"TelephoneSubmitFail"];
                if(showErrorHUD)
                    [SVProgressHUD showErrorWithStatus:errorMessage];
            } else {
                [NSUserDefaults standardUserDefaults].temporaryUser = temporaryUser;
                [SVProgressHUD showErrorWithStatus: OTLocalizedString(@"alreadyRegisteredMessage")];
                [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
            }
        }];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerSourceDictionary allKeys].count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerSourceDictionary allKeys][row];;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *key = [[self.pickerSourceDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)][row];
    self.countryCodeTxtField.text = [self.pickerSourceDictionary valueForKeyPath:[key stringByAppendingString:@".Code 2 char"]];
    self.codeCountry = [self.pickerSourceDictionary valueForKeyPath:[key stringByAppendingString:@".Number"]];
    self.codeCountry = [self.codeCountry substringToIndex:(self.codeCountry.length -1)];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [[self.pickerSourceDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)][row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}
@end
