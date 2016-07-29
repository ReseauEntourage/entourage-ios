//
//  OTOnboardingPhoneViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 06/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingPhoneViewController.h"
#import "IQKeyboardManager.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "UIScrollView+entourage.h"
#import "NSError+message.h"
#import "UIColor+entourage.h"

@interface OTOnboardingPhoneViewController ()

@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation OTOnboardingPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.continueButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
#if DEBUG //TARGET_IPHONE_SIMULATOR
    self.phoneTextField.text = @"+40724593579";
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [self.phoneTextField becomeFirstResponder];
}

- (IBAction)doContinue {
    OTUser *currentUser = [OTUser new];
    NSString *phone = self.phoneTextField.text;
    currentUser.phone = phone;
    
    [SVProgressHUD show];
    [[OTOnboardingService new] setupNewUserWithPhone:phone
        success:^(OTUser *onboardUser) {
            [SVProgressHUD dismiss];
            onboardUser.phone = phone;
            [[NSUserDefaults standardUserDefaults] setCurrentUser:onboardUser];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
        } failure:^(NSError *error) {
            NSString *errorMessage = [error userUpdateMessage];
#warning Create special message(code) on server-side
            if ([errorMessage isEqualToString:@"Phone n'est pas disponible"]) {
                [[NSUserDefaults standardUserDefaults] setCurrentUser:currentUser];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [SVProgressHUD showErrorWithStatus: OTLocalizedString(@"alreadyRegisteredMessage")];
                [[NSUserDefaults standardUserDefaults] setCurrentUser:currentUser];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
            } else {
                [SVProgressHUD showErrorWithStatus:errorMessage];
            }
            NSLog(@"ERR: something went wrong on onboarding user phone: %@", error.description);
        }];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint];
}

@end
