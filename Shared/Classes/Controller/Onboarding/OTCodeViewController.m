//
//  OTCodeViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 07/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

#import "OTCodeViewController.h"
#import "NSUserDefaults+OT.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "OTAuthService.h"
#import "UIScrollView+entourage.h"
#import "NSString+Validators.h"
#import "UIBarButtonItem+factory.h"
#import "UIStoryboard+entourage.h"
#import "OTOnboardingNavigationBehavior.h"
#import "entourage-Swift.h"

@interface OTCodeViewController ()

@property (nonatomic, weak) IBOutlet OnBoardingCodeTextField *codeTextField;
@property (nonatomic, weak) IBOutlet OnBoardingButton *validateButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, strong) IBOutlet OTOnboardingNavigationBehavior *onboardingNavigation;

@end

@implementation OTCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    [self addRegenerateBarButton];
    self.codeTextField.inputValidationChanged = ^(BOOL isValid) {
        self.validateButton.enabled = isValid;
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    
    //[self.continueButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    
    if([NSUserDefaults standardUserDefaults].currentUser) {
        [NSUserDefaults standardUserDefaults].temporaryUser = [NSUserDefaults standardUserDefaults].currentUser;
        [NSUserDefaults standardUserDefaults].currentUser = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTLogger logEvent:@"Screen30_3InputPasscodeView"];
    [self.codeTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

#pragma mark - Private

- (void)addRegenerateBarButton {
    UIBarButtonItem *regenerateButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doRegenerateCode")
                                                              withTarget:self
                                                               andAction:@selector(doRegenerateCode)
                                                                 andFont:@"SFUIText-Bold"
                                                                 colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:regenerateButton];
}

- (void)doRegenerateCode {
    NSString *phone = [NSUserDefaults standardUserDefaults].temporaryUser.phone;
    [SVProgressHUD show];
    [[OTAuthService new] regenerateSecretCode:phone success:^(OTUser *user) {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"requestSent")];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc] initWithTitle:OTLocalizedString(@"error") message:OTLocalizedString(@"requestNotSent") delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }];
}

- (IBAction)doContinue {
    NSString *phone = [NSUserDefaults standardUserDefaults].temporaryUser.phone;
    NSString *code = self.codeTextField.text;
    NSString *deviceAPNSid = [[NSUserDefaults standardUserDefaults] objectForKey:@DEVICE_TOKEN_KEY];
    [SVProgressHUD show];
    
    [[OTAuthService new] authWithPhone:phone password:code deviceId:deviceAPNSid success: ^(OTUser *user) {
        NSLog(@"User : %@ authenticated successfully", user.email);
        user.phone = phone;
        [SVProgressHUD dismiss];
        
        [NSUserDefaults standardUserDefaults].currentUser = user;
        [NSUserDefaults standardUserDefaults].temporaryUser = nil;
        

        if ([OTAppConfiguration shouldShowIntroTutorial]) {
            if ([NSUserDefaults standardUserDefaults].isTutorialCompleted) {
                [OTAppState navigateToAuthenticatedLandingScreen];
                return;
            }
        }

        [OTAppState continueFromLoginScreen];
        
    } failure: ^(NSError *error) {
        [SVProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"tryAgain") message:OTLocalizedString(@"invalidPhoneNumberOrCode") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"tryAgain_short") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction: defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

@end
