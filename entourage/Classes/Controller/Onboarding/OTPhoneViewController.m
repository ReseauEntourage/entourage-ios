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

@interface OTPhoneViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet OnBoardingNumberTextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, weak) IBOutlet OnBoardingButton *validateButton;
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTxtField;
@property (weak, nonatomic) IBOutlet UIPickerView *countryCodePicker;

@property (nonatomic, strong) NSArray *array;
@property (weak, nonatomic) IBOutlet UIView *pickerView;

@end

@implementation OTPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";

    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    self.phoneTextField.inputValidationChanged = ^(BOOL isValid) {
        self.validateButton.enabled = isValid;
    };
    self.array = @[@"FR", @"RO"];
    self.countryCodePicker.dataSource = self;
    self.countryCodePicker.delegate = self;
    self.countryCodeTxtField.delegate = self;
    self.phoneTextField.delegate = self;
    [self sourceForPicker];
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
//    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"TelephoneSubmit"];
    OTUser *temporaryUser = [OTUser new];
    NSString *phone = self.phoneTextField.text;
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

#pragma mark - UIPickerViewDelegate



#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.array.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
   // [self.view endEditing:YES];
    return self.array[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.countryCodeTxtField.text = self.array[row];
    //self.countryCodePicker.hidden = YES;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = self.array[row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.countryCodeTxtField) {
    
    }
}

- (NSMutableDictionary *)sourceForPicker {
    NSString *sourceFileString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CountryList.csv" ofType:@"csv"] encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *csvArray = [[NSMutableArray alloc] init];
    csvArray = [[sourceFileString componentsSeparatedByString:@"\n"] mutableCopy];
     NSString *keysString = [csvArray objectAtIndex:0];
    NSArray *keysArray = [keysString componentsSeparatedByString:@","];
    [csvArray removeObjectAtIndex:0];
    NSMutableDictionary *outputDict = [[NSMutableDictionary alloc]init];
    while (csvArray.count > 1)
    {
        NSString *tempString = [csvArray objectAtIndex:0];
        NSArray *tempArray = [tempString componentsSeparatedByString:@","];
        NSDictionary *tempDictionary = [[NSDictionary alloc]initWithObjects:tempArray forKeys:keysArray];
        [outputDict setObject:tempDictionary forKey:[tempArray objectAtIndex:0]];
        [csvArray removeObjectAtIndex:0];
    }
    return outputDict;
}

@end
