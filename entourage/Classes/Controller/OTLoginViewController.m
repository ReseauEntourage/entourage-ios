//
//  OTLoginViewController.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTLoginViewController.h"
#import "OTLostCodeViewController.h"
#import "OTConsts.h"
#import "IQKeyboardManager.h"
#import "OTUserEmailViewController.h"
#import "OTAuthService.h"
#import "UITextField+indentation.h"
#import "UIStoryboard+entourage.h"
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UINavigationController+entourage.h"
#import "UIView+entourage.h"
#import "UIScrollView+entourage.h"
#import "UITextField+indentation.h"
#import "OTUser.h"
#import "UIColor+entourage.h"
#import "SVProgressHUD.h"
#import "OTOnboardingNavigationBehavior.h"
#import "OTPushNotificationsService.h"
#import "OTAskMoreViewController.h"
#import "NSError+OTErrorData.h"
#import "OTLocationManager.h"
#import "OTUserNameViewController.h"
#import "entourage-Swift.h"
#import "OTCountryCodePickerViewDataSource.h"
#import "UIColor+entourage.h"
#import "Mixpanel/Mixpanel.h"
#import "OTDeepLinkService.h"

NSString *const kTutorialDone = @"has_done_tutorial";

@interface OTLoginViewController ()
<
    LostCodeDelegate,
    OTUserNameViewControllerDelegate,
    UIPickerViewDelegate,
    UIPickerViewDataSource,
    UITextFieldDelegate
>

@property (weak, nonatomic) IBOutlet OnBoardingNumberTextField *phoneTextField;
@property (weak, nonatomic) IBOutlet OnBoardingCodeTextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, strong) IBOutlet OTOnboardingNavigationBehavior *onboardingNavigation;
@property (nonatomic, weak) IBOutlet OnBoardingButton *continueButton;
@property (nonatomic, weak) IBOutlet UIView *pickerView;
@property (nonatomic, weak) IBOutlet UIPickerView *countryCodePicker;
@property (nonatomic, weak) IBOutlet JVFloatLabeledTextField *countryCodeTxtField;

@property (nonatomic, assign) BOOL phoneIsValid;
@property (nonatomic, weak) NSString *codeCountry;
@property (nonatomic, weak) OTCountryCodePickerViewDataSource *pickerDataSource;

@end

@implementation OTLoginViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    self.phoneIsValid = NO;
    self.phoneTextField.inputValidationChanged = ^(BOOL isValid) {
        self.phoneIsValid = YES;
        self.continueButton.enabled = [self validateForm];
    };
    self.passwordTextField.inputValidationChanged = ^(BOOL isValid) {
        self.continueButton.enabled = [self validateForm];
    };
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
   
    [self.passwordTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.passwordTextField indentRight];
    [self.countryCodeTxtField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    self.countryCodeTxtField.keepBaseline = YES;
    self.countryCodeTxtField.floatingLabelTextColor = [UIColor clearColor];
    self.countryCodeTxtField.floatingLabelActiveTextColor = [UIColor clearColor];
    self.pickerDataSource = [OTCountryCodePickerViewDataSource sharedInstance];
    self.codeCountry = @"+33";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [OTLogger logEvent:@"Screen02OnboardingLoginView"];
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.phoneTextField indentRight];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 10;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.countryCodeTxtField.inputView = self.pickerView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
    UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];
}

-(IBAction)resendCode:(id)sender {
    [OTLogger logEvent:@"SMSCodeRequest"];
    [OTLogger logEvent:@"Screen03_1OnboardingCodeResendView"];
    [self performSegueWithIdentifier:@"ResendCodeSegue" sender:nil];
}

#pragma mark - Public Methods

- (BOOL)validateForm {
    return self.phoneIsValid && (self.passwordTextField.text.length == 6);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)launchAuthentication {
    [SVProgressHUD show];
    NSString *deviceAPNSid = [[NSUserDefaults standardUserDefaults] objectForKey:@DEVICE_TOKEN_KEY];
    NSString *phone = self.phoneTextField.text;
    if([self.phoneTextField.text hasPrefix:@"0"])
        phone = [self.phoneTextField.text substringFromIndex:1];
    [[OTAuthService new] authWithPhone:[self.codeCountry stringByAppendingString: phone]
                              password:self.passwordTextField.text
                              deviceId:deviceAPNSid
                               success: ^(OTUser *user) {
                                   [OTLogger logEvent:@"Login_Success"];
                                   NSLog(@"User : %@ authenticated successfully", user.email);
                                   [self setupMixpanelWithUser:user];
                                   user.phone = [self.codeCountry stringByAppendingString:phone];
                                   NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
                                   if (loggedNumbers == nil)
                                       loggedNumbers = [NSMutableArray new];
                                   [SVProgressHUD dismiss];
                                   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
                                   [NSUserDefaults standardUserDefaults].currentUser = user;
                                   [[NSUserDefaults standardUserDefaults] synchronize];

                                   if ([loggedNumbers containsObject:user.phone] && !deviceAPNSid) {
                                       [[OTPushNotificationsService new] promptUserForPushNotifications];
                                       [UIStoryboard showSWRevealController];
                                   }
                                   if (self.fromLink && [self.fromLink isEqualToString:@"badge"]) {
                                       [[OTDeepLinkService new] handleFeedAndBadgeLinks:self.fromLink];
                                       self.fromLink = nil;
                                   }
                                   else {
                                       [self.onboardingNavigation nextFromLogin];
                                   }
                                   [[OTLocationManager sharedInstance] startLocationUpdates];
                               } failure: ^(NSError *error) {
                                   [SVProgressHUD dismiss];
                                   [OTLogger logEvent:@"TelephoneSubmitFail"];
                                   NSString *alertTitle = OTLocalizedString(@"error");
                                   NSString *alertText = OTLocalizedString(@"connection_error");
                                   NSString *buttonTitle = @"ok";
                                   NSString *errorCode = [error readErrorCode];
                                   if ([errorCode isEqualToString:UNAUTHORIZED]) {
                                       alertTitle = OTLocalizedString(@"tryAgain");
                                       alertText = OTLocalizedString(@"invalidPhoneNumberOrCode");
                                       buttonTitle = OTLocalizedString(@"tryAgain_short");
                                       [OTLogger logEvent:@"Login_Error"];
                                       [OTLogger logEvent:@"TelephoneSubmitError"];
                                   }
                                   else if([errorCode isEqualToString:INVALID_PHONE_FORMAT]) {
                                       alertTitle = OTLocalizedString(@"tryAgain");
                                       alertText = OTLocalizedString(@"invalidPhoneNumberFormat");
                                       buttonTitle = OTLocalizedString(@"tryAgain_short");
                                       [OTLogger logEvent:@"Login_Error"];
                                       [OTLogger logEvent:@"TelephoneSubmitError"];
                                   }
                                   else if(error.code == NSURLErrorNotConnectedToInternet) {
                                       alertTitle = OTLocalizedString(@"tryAgain");
                                       buttonTitle = OTLocalizedString(@"tryAgain_short");
                                       alertText = error.localizedDescription;
                                       [OTLogger logEvent:@"Login_Error"];
                                   }
                                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertText preferredStyle:UIAlertControllerStyleAlert];
                                   UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
                                   [alert addAction: defaultAction];
                                   [self presentViewController:alert animated:YES completion:nil];

                               }];
}

- (void)setupMixpanelWithUser: (OTUser *)user {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[user.sid stringValue]];
    [mixpanel.people set:@{@"$email": user.email != nil ? user.email : @""}];
    [mixpanel.people set:@{@"EntouragePartner": user.partner != nil ? user.partner.name : @""}];
    [mixpanel.people set:@{@"EntourageUserType": user.type}];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ResendCodeSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTLostCodeViewController *controller = (OTLostCodeViewController *)navController.viewControllers.firstObject;
        controller.codeDelegate = self;
        long code = [self.countryCodePicker selectedRowInComponent:0];
        controller.countryCodeTextField.text = [self.pickerDataSource getCountryShortNameForRow:code];
        controller.codeCountry = [self.pickerDataSource getCountryCodeForRow:code];
        controller.rowCode = code;
        controller.phoneTextField.text = self.phoneTextField.text;
    }
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)validateButtonDidTap {
    [OTLogger logEvent:@"TelephoneSubmit"];
    [self launchAuthentication];
}

/********************************************************************************/
#pragma mark - LostCodeDelegate

- (void)loginWithNewCode:(NSString *)code {
    [self dismissViewControllerAnimated:YES completion:^() {
        self.passwordTextField.text = code;
        [self validateButtonDidTap];
    }];
}

- (void)loginWithCountryCode:(long)code andPhoneNumber:(NSString *)phone {
    [self dismissViewControllerAnimated:YES completion:^() {
        self.countryCodeTxtField.text = [self.pickerDataSource getCountryShortNameForRow:code];
        self.codeCountry = [self.pickerDataSource getCountryCodeForRow:code];
        self.phoneTextField.text = phone;
    }];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint andMarker:self.phoneTextField];
}

/********************************************************************************/
#pragma mark - OTUserNameViewController

- (void)userNameDidChange {
    [UIStoryboard showSWRevealController];
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
    self.countryCodeTxtField.text = [self.pickerDataSource getCountryShortNameForRow:row];
    self.codeCountry = [self.pickerDataSource getCountryCodeForRow:row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.pickerDataSource getTitleForRow:row];
    NSAttributedString *attString =
    [[NSAttributedString alloc] initWithString:title
                                    attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}

@end
