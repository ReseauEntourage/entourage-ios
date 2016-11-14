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

#define SHOW_LOGIN_SEGUE @"WelcomeLoginSegue"
#define CONTINUE_ONBOARDING_SEGUE @"SegueOnboarding"

@interface OTWelcomeViewController ()

@property (nonatomic, weak) IBOutlet UITextView *txtTerms;

@end

@implementation OTWelcomeViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    if(![NSUserDefaults standardUserDefaults].currentUser)
        [self addLoginBarButton];
    self.txtTerms.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    self.txtTerms.attributedText = [self buildTermsWithLink];
}

#pragma mark - Private

- (void)addLoginBarButton {
    UIBarButtonItem *loginButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doLogin") withTarget:self andAction:@selector(doLogin) colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:loginButton];
}

- (NSAttributedString *)buildTermsWithLink {
    NSString *stringToMakeInLink = OTLocalizedString(@"terms_and_conditions_for_onboarding");
    NSRange range = [self.txtTerms.text rangeOfString:stringToMakeInLink];
    if(range.location == NSNotFound)
        return [[NSAttributedString alloc] initWithString:self.txtTerms.text];
    NSRange fullRange = NSMakeRange(0, self.txtTerms.text.length);
    NSMutableAttributedString *source = [[NSMutableAttributedString alloc] initWithString:self.txtTerms.text];
    [source addAttribute:NSLinkAttributeName value:ABOUT_CGU_URL range:range];
    [source addAttribute:NSFontAttributeName value:self.txtTerms.font range:fullRange];
    [source addAttribute:NSForegroundColorAttributeName value:self.txtTerms.textColor range:fullRange];
    return source;
}

#pragma mark - IBActions

- (void)doLogin {
    [self performSegueWithIdentifier:SHOW_LOGIN_SEGUE sender:self];
}

- (IBAction)continueOnboarding:(id)sender {
    [Flurry logEvent:@"WelcomeScreenContinue"];
    [self performSegueWithIdentifier:CONTINUE_ONBOARDING_SEGUE sender:self];
}

@end
