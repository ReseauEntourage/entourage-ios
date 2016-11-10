//
//  OTPhoneViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 06/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPhoneViewController.h"
#import "IQKeyboardManager.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "UIScrollView+entourage.h"
#import "UIColor+entourage.h"
#import "NSError+OTErrorData.h"
#import "OTConsts.h"
#import "OTDeepLinkService.h"

@interface OTPhoneViewController ()

@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation OTPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"";
    
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.phoneTextField becomeFirstResponder];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (IBAction)doContinue {
    [Flurry logEvent:@"TelephoneSubmit"];
    OTUser *temporaryUser = [OTUser new];
    NSString *phone = self.phoneTextField.text;
    temporaryUser.phone = phone;
    
    [SVProgressHUD show];
    [[OTOnboardingService new] setupNewUserWithPhone:phone
        success:^(OTUser *onboardUser) {
            [SVProgressHUD dismiss];
            onboardUser.phone = phone;
            [NSUserDefaults standardUserDefaults].temporaryUser = onboardUser;
            [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSString *errorMessage = error.localizedDescription;
            NSString *errorCode = [error readErrorCode];
            BOOL showErrorHUD = YES;
            if([errorCode isEqualToString:INVALID_PHONE_FORMAT]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:OTLocalizedString(@"invalidPhoneNumberFormat") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"close") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                [alert addAction:defaultAction];
                UIAlertAction *openLoginAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"already_subscribed") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[OTDeepLinkService new] navigateToLogin];
                }];
                [alert addAction:openLoginAction];
                [self presentViewController:alert animated:YES completion:nil];
                showErrorHUD = NO;
            }
            else if([errorCode isEqualToString:PHONE_ALREADY_EXIST]) {
                errorMessage = OTLocalizedString(@"phoneAlreadyExits");
            }
            if (errorMessage) {
                [Flurry logEvent:@"TelephoneSubmitFail"];
                if(showErrorHUD)
                    [SVProgressHUD showErrorWithStatus:errorMessage];
            } else {
                [NSUserDefaults standardUserDefaults].temporaryUser = temporaryUser;
                [SVProgressHUD showErrorWithStatus: OTLocalizedString(@"alreadyRegisteredMessage")];
                [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
            }
        }];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint];
}

@end
