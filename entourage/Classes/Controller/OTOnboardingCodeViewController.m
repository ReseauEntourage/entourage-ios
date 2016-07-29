//
//  OTOnboardingCodeViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 07/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingCodeViewController.h"
#import "IQKeyboardManager.h"
#import "NSUserDefaults+OT.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "OTAuthService.h"
#import "UIScrollView+entourage.h"
#import "NSString+Validators.h"
#import "UIBarButtonItem+factory.h"

@interface OTOnboardingCodeViewController ()

@property (nonatomic, weak) IBOutlet UITextField *codeTextField;
@property (nonatomic, weak) IBOutlet UIButton *validateButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation OTOnboardingCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"";
    [self addRegenerateBarButton];
    
    [self.codeTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.validateButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
}

#pragma mark - Private

- (void)addRegenerateBarButton {
    UIBarButtonItem *regenerateButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doRegenerateCode").capitalizedString withTarget:self andAction:@selector(doRegenerateCode) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:regenerateButton];
}


- (void)viewDidAppear:(BOOL)animated {
    [self.codeTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)doRegenerateCode {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [userDefaults currentUser].phone;
    [SVProgressHUD show];
    [[OTAuthService new] regenerateSecretCode:phone.phoneNumberServerRepresentation
                                      success:^(OTUser *user) {
                                          [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"requestSent")];
                                      }
                                      failure:^(NSError *error) {
                                          [SVProgressHUD dismiss];
                                          [[[UIAlertView alloc]
                                            initWithTitle:OTLocalizedString(@"error") //@"Erreur"
                                            message:OTLocalizedString(@"requestNotSent")// @"Echec lors de la demande"
                                            delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Ok",
                                            nil] show];
                                      }];
}

- (IBAction)doContinue {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [userDefaults currentUser].phone;
    NSString *code = self.codeTextField.text;
    NSString *deviceAPNSid = [userDefaults objectForKey:@"device_token"];
    [SVProgressHUD show];
    
    [[OTAuthService new] authWithPhone:phone
                              password:code
                              deviceId:deviceAPNSid
                               success: ^(OTUser *user) {
                                   NSLog(@"User : %@ authenticated successfully", user.email);
                                   user.phone = phone;
                                   [SVProgressHUD dismiss];
                                   
                                   [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   [self performSegueWithIdentifier:@"CodeToEmailSegue" sender:self];
                               } failure: ^(NSError *error) {
                                   [SVProgressHUD showErrorWithStatus:@""];
                               }];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification
                                         andHeightContraint:self.heightContraint];
}

@end
