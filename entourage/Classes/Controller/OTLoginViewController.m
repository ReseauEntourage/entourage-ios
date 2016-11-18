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


NSString *const kTutorialDone = @"has_done_tutorial";

@interface OTLoginViewController () <LostCodeDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, strong) IBOutlet OTOnboardingNavigationBehavior *onboardingNavigation;

@end

@implementation OTLoginViewController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"";
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [self.phoneTextField indentRight];
    [self.passwordTextField indentRight];
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.passwordTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.phoneTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
    UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];
}

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
    NSString *deviceAPNSid = [[NSUserDefaults standardUserDefaults] objectForKey:@DEVICE_TOKEN_KEY];
    [[OTAuthService new] authWithPhone:self.phoneTextField.text
                              password:self.passwordTextField.text
                              deviceId:deviceAPNSid
                               success: ^(OTUser *user) {
                                   NSLog(@"User : %@ authenticated successfully", user.email);
                                   user.phone = self.phoneTextField.text;
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
                                   else
                                       [self.onboardingNavigation nextFromLogin];
                               } failure: ^(NSError *error) {
                                   [SVProgressHUD dismiss];
                                   NSString *alertTitle = OTLocalizedString(@"error");
                                   NSString *alertText = OTLocalizedString(@"connection_error");
                                   NSString *buttonTitle = @"ok";
                                   NSString *errorCode = [error readErrorCode];
                                   if ([errorCode isEqualToString:UNAUTHORIZED]) {
                                       alertTitle = OTLocalizedString(@"tryAgain");
                                       alertText = OTLocalizedString(@"invalidPhoneNumberOrCode");
                                       buttonTitle = OTLocalizedString(@"tryAgain_short");
                                   }
                                   else if([errorCode isEqualToString:INVALID_PHONE_FORMAT]) {
                                       alertTitle = OTLocalizedString(@"tryAgain");
                                       alertText = OTLocalizedString(@"invalidPhoneNumberFormat");
                                       buttonTitle = OTLocalizedString(@"tryAgain_short");
                                   }
                                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertText preferredStyle:UIAlertControllerStyleAlert];
                                   UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
                                   [alert addAction: defaultAction];
                                   [self presentViewController:alert animated:YES completion:nil];
                                   
                               }];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OTLostCode"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTLostCodeViewController *controller = (OTLostCodeViewController *)navController.viewControllers.firstObject;
        controller.codeDelegate = self;
    }
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)validateButtonDidTad {
    if (self.phoneTextField.text.length == 0) {
        [[[UIAlertView alloc]
          initWithTitle:OTLocalizedString(@"connection_imposible")
          message:OTLocalizedString(@"retryPhone")
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
          nil] show];
    }
    else if (!self.validateForm) {
        [[[UIAlertView alloc]
          initWithTitle:OTLocalizedString(@"connection_imposible")
          message:OTLocalizedString(@"invalidPhoneNumber")
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
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

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint andMarker:self.phoneTextField];
}

@end
