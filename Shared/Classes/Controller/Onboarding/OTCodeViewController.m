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
@property (nonatomic, weak) IBOutlet UILabel *topTitle;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *privacyIcon;
@property (nonatomic, weak) IBOutlet OnBoardingButton *validateButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, strong) IBOutlet OTOnboardingNavigationBehavior *onboardingNavigation;
@property (nonatomic, weak) IBOutlet UIButton *regenerateCodeButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIView *bottomContainer;

@property (nonatomic) BOOL showFullDescription;

@end

@implementation OTCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    self.showFullDescription = NO;
    
    self.bottomContainer.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    [self.backButton setImage:[[self.backButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.backButton.tintColor = [ApplicationTheme shared].backgroundThemeColor;
    
    self.codeTextField.inputValidationChanged = ^(BOOL isValid) {
        self.validateButton.enabled = isValid;
    };
    
    self.privacyIcon.image = [self.privacyIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.privacyIcon.tintColor = [UIColor whiteColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Vous avez reçu un code (normalement)" attributes:@{
                                                                                                                                                         NSFontAttributeName: [UIFont systemFontOfSize:22.0f weight:UIFontWeightSemibold],
                                                                                                                                                         NSForegroundColorAttributeName: [ApplicationTheme shared].backgroundThemeColor,
                                                                                                                                                         NSKernAttributeName: @(0.0)
                                                                                                                                                         }];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular] range:NSMakeRange(23, 13)];
    
    self.topTitle.attributedText = attributedString;
    [self updateSubtitleLabel];
}

- (void)updateSubtitleLabel {
    NSString *text = self.showFullDescription ? [OTAppAppearance lostCodeFullDescription] : [OTAppAppearance lostCodeSimpleDescription];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"SFUIText-Light" size:14]}];
    NSRange range1 = [text.lowercaseString rangeOfString:OTLocalizedString(@"doRegenerateCode").lowercaseString];
    
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range1];
    [attributedText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range1];
    [attributedText addAttribute:NSUnderlineColorAttributeName value:[UIColor whiteColor] range:range1];
    
    self.descriptionLabel.attributedText = attributedText;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
    [self.validateButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    
    if ([NSUserDefaults standardUserDefaults].currentUser) {
        [NSUserDefaults standardUserDefaults].temporaryUser = [NSUserDefaults standardUserDefaults].currentUser;
        [NSUserDefaults standardUserDefaults].currentUser = nil;
    }
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTLogger logEvent:@"Screen30_3InputPasscodeView"];
    [self.codeTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
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

- (IBAction)doRegenerateCode {
    
    self.showFullDescription = YES;
    [self updateSubtitleLabel];
    
    if ([NSUserDefaults standardUserDefaults].currentUser) {
        [NSUserDefaults standardUserDefaults].temporaryUser = [NSUserDefaults standardUserDefaults].currentUser;
        [NSUserDefaults standardUserDefaults].currentUser = nil;
    }
    
    NSString *phone = [NSUserDefaults standardUserDefaults].temporaryUser.phone;
    [SVProgressHUD show];
    [[OTAuthService new] regenerateSecretCode:phone success:^(OTUser *user) {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"requestSent")];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"error")
                                                                            message:OTLocalizedString(@"requestNotSent")
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

- (IBAction)backAction {
    [self.navigationController popViewControllerAnimated:YES];
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
