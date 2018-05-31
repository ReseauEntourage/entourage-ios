//
//  OTUserEmailViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 08/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTUserEmailViewController.h"
#import "OTUserNameViewController.h"

#import "IQKeyboardManager.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "UIScrollView+entourage.h"
#import "NSUserDefaults+OT.h"
#import "OTAuthService.h"
#import "OTOnboardingNavigationBehavior.h"
#import "UIBarButtonItem+factory.h"
#import "entourage-Swift.h"
#import "NSString+Validators.h"
#import "OTScrollPinBehavior.h"
#import "entourage-Swift.h"

@interface OTUserEmailViewController ()

@property (nonatomic, weak) IBOutlet OnBoardingTextField *emailTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet OTOnboardingNavigationBehavior *onboardingNavigation;
@property (nonatomic, weak) IBOutlet OnBoardingButton *continueButton;
@property (weak, nonatomic) IBOutlet OTScrollPinBehavior *scrollBehavior;
@property (weak, nonatomic) IBOutlet UILabel *emailDescLabel;

@end

@implementation OTUserEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    self.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    
    [self.emailTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    self.emailTextField.inputValidationChanged = ^(BOOL isValid) {
        self.continueButton.enabled = [self.emailTextField.text isValidEmail];
    };
    [self.continueButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    
    self.emailDescLabel.text = [OTAppAppearance userProfileEmailDescription];
    
    [self loadCurrentData];
    [self addIgnoreButton];
}

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doIgnore").capitalizedString
                                                          withTarget:self
                                                           andAction:@selector(doIgnore)
                                                             andFont:@"SFUIText-Bold"
                                                             colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //[self.scrollBehavior initialize];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTLogger logEvent:@"OTUserEmailViewController"];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.emailTextField becomeFirstResponder];
    
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)loadCurrentData {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if(currentUser)
        self.emailTextField.text = currentUser.email;
}

- (IBAction)doContinue {
    [OTLogger logEvent:@"EmailSubmit"];
    NSString *email = self.emailTextField.text;
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    currentUser.email = email;

    [SVProgressHUD show];
    [[OTAuthService new] updateUserInformationWithUser:currentUser
                                               success:^(OTUser *user) {
                                                   // TODO phone is not in response so need to restore it manually
                                                   user.phone = currentUser.phone;
                                                   [NSUserDefaults standardUserDefaults].currentUser = user;
                                                   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];

                                                   [SVProgressHUD dismiss];
                                                   [self.onboardingNavigation nextFromEmail];
                                               }
                                               failure:^(NSError *error) {
                                                   [OTLogger logEvent:@"EmailSubmitError"];
                                                   [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                   NSLog(@"ERR: something went wrong on onboarding user email: %@", error.description);
                                               }];
}

- (void)doIgnore {
    [SVProgressHUD dismiss];
    [self.onboardingNavigation nextFromEmail];
}

@end
