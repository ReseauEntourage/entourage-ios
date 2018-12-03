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
@property (nonatomic, weak) IBOutlet UITextView *txtTermsTop;
@property (nonatomic, weak) IBOutlet UITextView *txtTermsBottom;
@property (nonatomic, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, weak) IBOutlet UIImageView *welcomeLogo;
@property (nonatomic, weak) IBOutlet UIImageView *welcomeImage;

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
        self.txtTermsTop.text = [OTAppAppearance welcomeTopDescription];
        self.welcomeLogo.image = [OTAppAppearance welcomeLogo];
        self.welcomeImage.image = [OTAppAppearance welcomeImage];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.txtTermsBottom.attributedText];
        NSRange range1 = [self.txtTermsBottom.text rangeOfString:OTLocalizedString(@"terms_and_conditions_for_onboarding")];
        NSRange range2 = [self.txtTermsBottom.text rangeOfString:OTLocalizedString(@"policy_for_onboarding")];
        
        [attributedText addAttribute:NSLinkAttributeName value:[OTAppAppearance aboutUrlString] range:range1];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range1];
        [attributedText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range1];
        [attributedText addAttribute:NSUnderlineColorAttributeName value:[UIColor whiteColor] range:range1];
        
        [attributedText addAttribute:NSLinkAttributeName value:[OTAppAppearance policyUrlString] range:range2];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range2];
        [attributedText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range2];
        [attributedText addAttribute:NSUnderlineColorAttributeName value:[UIColor whiteColor] range:range2];
        
        self.txtTermsBottom.attributedText = attributedText;
        self.txtTermsBottom.linkTextAttributes = @{NSForegroundColorAttributeName: self.txtTermsBottom.textColor, NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
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
        [OTAppState continueFromWelcomeScreenForOnboarding: YES];
    } else {
        [OTAppState continueFromWelcomeScreen: YES];
    }
}

@end
