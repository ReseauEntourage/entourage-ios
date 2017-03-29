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

#define SHOW_LOGIN_SEGUE @"WelcomeLoginSegue"
#define CONTINUE_ONBOARDING_SEGUE @"SegueOnboarding"

@interface OTWelcomeViewController ()

@property (nonatomic, weak) IBOutlet UITextView *txtTerms;

@end

@implementation OTWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    if(![NSUserDefaults standardUserDefaults].currentUser) {
        [self addLoginBarButton];
        [NSAttributedString applyLinkOnTextView:self.txtTerms 
            withText:self.txtTerms.text 
            toLinkText:OTLocalizedString(@"terms_and_conditions_for_onboarding") 
            withLink:ABOUT_CGU_URL];
    }
}

#pragma mark - Private

- (void)addLoginBarButton {
    UIBarButtonItem *loginButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doLogin") withTarget:self andAction:@selector(doLogin) colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:loginButton];
}

#pragma mark - IBActions

- (void)doLogin {
    [self performSegueWithIdentifier:SHOW_LOGIN_SEGUE sender:self];
}

- (IBAction)continueOnboarding:(id)sender {
    [OTLogger logEvent:@"WelcomeScreenContinue"];
    [self performSegueWithIdentifier:CONTINUE_ONBOARDING_SEGUE sender:self];
}

@end
