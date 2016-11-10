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

@interface OTUserEmailViewController ()

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;
@property (nonatomic, strong) IBOutlet OTOnboardingNavigationBehavior *onboardingNavigation;

@end

@implementation OTUserEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"";
    [self.emailTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [self loadCurrentData];

    [self addIgnoreButton];
}

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doIgnore").capitalizedString
                                                          withTarget:self
                                                           andAction:@selector(doIgnore)
                                                             colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)loadCurrentData {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if(currentUser)
        self.emailTextField.text = currentUser.email;
}

- (IBAction)doContinue {
    [Flurry logEvent:@"EmailSubmit"];
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
                                                   [Flurry logEvent:@"EmailSubmitError"];
                                                   [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                   NSLog(@"ERR: something went wrong on onboarding user email: %@", error.description);
                                               }];
}

- (void)doIgnore {
    [SVProgressHUD dismiss];
    [self.onboardingNavigation nextFromEmail];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification
                                         andHeightContraint:self.heightContraint];
}

@end
