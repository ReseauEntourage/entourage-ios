//
//  OTLoginViewController.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTLoginViewController.h"

// Controller
#import "OTLostCodeViewController.h"
#import "OTConsts.h"
#import "IQKeyboardManager.h"
#import "OTUserEmailViewController.h"

// Service
#import "OTAuthService.h"
#import "OTJSONResponseSerializer.h"

// Utils
#import "UITextField+indentation.h"
#import "UIStoryboard+entourage.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UINavigationController+entourage.h"
#import "UIView+entourage.h"
#import "UIScrollView+entourage.h"
#import "UITextField+indentation.h"
// Model
#import "OTUser.h"
#import "UIColor+entourage.h"

// View
#import "SVProgressHUD.h"

/********************************************************************************/
#pragma mark - Constants
NSString *const kTutorialDone = @"has_done_tutorial";

/********************************************************************************/
#pragma mark - OTLoginViewController

@interface OTLoginViewController () <LostCodeDelegate>

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurEffect;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIView *whiteBackground;
@property (weak, nonatomic) IBOutlet UIButton *askMoreButton;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
@property (weak, nonatomic) IBOutlet UIButton *lostCodeButton;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation OTLoginViewController

/********************************************************************************/
#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"";
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
	self.whiteBackground.layer.cornerRadius = 5;
	self.whiteBackground.layer.masksToBounds = YES;
    
    [self.phoneTextField indentRight];
    [self.passwordTextField indentRight];
    [self.phoneTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.passwordTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.validateButton setupHalfRoundedCorners];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
#if DEBUG
    // Ciprian Public - Staging
    //self.phoneTextField.text = @"+40723199641";
//    self.phoneTextField.text = @"+40724591114";
//    self.phoneTextField.text = @"+40723199642";
//    self.phoneTextField.text = @"+40724591112";
    
    // Ciprian Pro - Prod
    //self.phoneTextField.text = @"+40740884267";
    // Br
    self.phoneTextField.text = @"+40742224359";
    
    //Vincent
    //self.phoneTextField.text = @"0651502173";

    // Ciprian + Mihai
    // self.phoneTextField.text = @"0623456789";

    // Vasile Pro - Prod
    //self.phoneTextField.text = @"+40723199641";
    
    
    // Vincent PRO
    //self.phoneTextField.text = @"+33651502173";
    
    // Public Staging
    //self.phoneTextField.text = @"+40723199642";
    
    // JM
    //self.phoneTextField.text = @"0783601123";
    self.passwordTextField.text = @"123456";
    
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.phoneTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
    UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];
}

/********************************************************************************/
#pragma mark - Public Methods

- (BOOL)validateForm {
    return [self.phoneTextField.text isValidPhoneNumber];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)launchAuthentication {
    [SVProgressHUD show];
    NSString *deviceAPNSid = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
    [[OTAuthService new] authWithPhone:self.phoneTextField.text
                              password:self.passwordTextField.text
                              deviceId:deviceAPNSid
                               success: ^(OTUser *user) {
                                   NSLog(@"User : %@ authenticated successfully", user.email);
                                   user.phone = self.phoneTextField.text;
                                   NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
                                   if (loggedNumbers == nil)
                                       loggedNumbers = [NSMutableArray new];
                                   [SVProgressHUD dismiss];
                                   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
                                   [NSUserDefaults standardUserDefaults].currentUser = user;
                                   if ([loggedNumbers containsObject:user.phone] && !deviceAPNSid)
                                       [UIStoryboard showSWRevealController];
                                   else
                                       [self performSegueWithIdentifier:@"UserProfileDetailsSegue" sender:self];
                               } failure: ^(NSError *error) {
                                   [SVProgressHUD dismiss];
                                   NSString *alertTitle = OTLocalizedString(@"error");
                                   NSString *alertText = OTLocalizedString(@"connection_error");
                                   NSString *buttonTitle = @"ok";
                                   if ([[error.userInfo valueForKey:JSONResponseSerializerWithDataKey] isEqualToString:@"unauthorized"]) {
                                       alertTitle = OTLocalizedString(@"tryAgain");
                                       alertText = OTLocalizedString(@"invalidPhoneNumberOrCode");
                                       buttonTitle = OTLocalizedString(@"tryAgain_short");
                                   }
                                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                                  message:alertText
                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                   UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:buttonTitle
                                                                                           style:UIAlertActionStyleDefault
                                                                                         handler:^(UIAlertAction * _Nonnull action) {}];
                                   [alert addAction: defaultAction];
                                   [self presentViewController:alert animated:YES completion:nil];
                                   
                               }];
}

/********************************************************************************/
#pragma mark - OTAskMoreViewControllerDelegate

- (void)hideBlurEffect {
    [UIView animateWithDuration:0.5 animations:^(void) {
        [self.blurEffect setAlpha:0.0];
    }];
}

/********************************************************************************/
#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OTAskMore"]) {
        OTAskMoreViewController *controller = (OTAskMoreViewController *)segue.destinationViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"OTLostCode"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTLostCodeViewController *controller = (OTLostCodeViewController *)navController.viewControllers.firstObject;
        controller.codeDelegate = self;
    }
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)displayAskMoreModal:(id)sender {
    [self.blurEffect setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^(void) {
        [self.blurEffect setAlpha:0.7];
    }];
    [self performSegueWithIdentifier:@"OTAskMore" sender:self];
}

- (IBAction)validateButtonDidTad {
    if (self.phoneTextField.text.length == 0) {
        [[[UIAlertView alloc]
          initWithTitle:OTLocalizedString(@"connection_imposible")
          message:OTLocalizedString(@"retryPhone")
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
          nil] show];
    }
    else if (!self.validateForm) {
        [[[UIAlertView alloc]
          initWithTitle:OTLocalizedString(@"connection_imposible")
          message:OTLocalizedString(@"invalidPhoneNumber")
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"Ok",
          nil] show];
    }
    else {
        [self launchAuthentication];
    }
}

/********************************************************************************/
#pragma mark - LostCodeDelegate

- (void)loginWithNewCode:(NSString *)code {
    [self dismissViewControllerAnimated:YES completion:^() {
        self.passwordTextField.text = code;
        [self validateButtonDidTad];
    }];
}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint andMarker:self.phoneTextField];
}

@end
