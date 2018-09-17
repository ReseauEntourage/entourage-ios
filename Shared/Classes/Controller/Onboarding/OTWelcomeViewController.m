//
//  OTWelcomeViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 06/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTWelcomeViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "UIView+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "NSUserDefaults+OT.h"
#import "NSAttributedString+OTBuilder.h"
#import "OTLogger.h"
#import "entourage-Swift.h"

#define SHOW_LOGIN_SEGUE @"WelcomeLoginSegue"
#define CONTINUE_ONBOARDING_SEGUE @"SegueOnboarding"

@interface OTWelcomeViewController ()

@property (nonatomic, weak) IBOutlet UILabel *welcomeTitleLabel;
@property (nonatomic, weak) IBOutlet UITextView *txtTerms;
@property (nonatomic, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, weak) IBOutlet UIImageView *welcomeLogo;

@end

@implementation OTWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;

    self.title = @"";
    if (![NSUserDefaults standardUserDefaults].currentUser) {
        [self addLoginBarButton];
        
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        self.welcomeTitleLabel.text = [NSString stringWithFormat:@"Bienvenue sur %@", appName];
        self.txtTerms.text = [OTAppAppearance welcomeDescription];
        self.welcomeLogo.image = [OTAppAppearance welcomeLogo];
        
        [NSAttributedString applyLinkOnTextView:self.txtTerms 
            withText:self.txtTerms.text 
            toLinkText:OTLocalizedString(@"terms_and_conditions_for_onboarding") 
            withLink:[OTAppAppearance aboutUrlString]];
    }
    
    [self.continueButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTLogger logEvent:@"Screen30_1WelcomeView"];
}

#pragma mark - Private

- (void)addLoginBarButton {
    if ([OTAppConfiguration shouldAllowLoginFromWelcomeScreen]) {
        UIBarButtonItem *loginButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doLogin")
                                                         withTarget:self
                                                          andAction:@selector(doLogin)
                                                            andFont:@"SFUIText-Bold"
                                                            colored:[UIColor whiteColor]];
        [self.navigationItem setRightBarButtonItem:loginButton];
    }
}

#pragma mark - IBActions

- (void)doLogin {
    [self performSegueWithIdentifier:SHOW_LOGIN_SEGUE sender:self];
}

- (IBAction)continueOnboarding:(id)sender {
    if (self.signupNewUser) {
        [OTAppState continueFromWelcomeScreenForOnboarding];
    } else {
        [OTAppState continueFromWelcomeScreen];
    }
}

@end
