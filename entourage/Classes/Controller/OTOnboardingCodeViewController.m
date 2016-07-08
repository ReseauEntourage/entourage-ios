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
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "OTAuthService.h"

@interface OTOnboardingCodeViewController ()

@property (nonatomic, weak) IBOutlet UITextField *codeTextField;
@property (nonatomic, weak) IBOutlet UIButton *validateButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation OTOnboardingCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addRegenerateBarButton];
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.codeTextField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:.7] }];
    self.codeTextField.attributedPlaceholder = str;
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.validateButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
}

#pragma mark - Private

- (void)addRegenerateBarButton {
    UIBarButtonItem *regenerateButton = [[UIBarButtonItem alloc] initWithTitle:OTLocalizedString(@"doRegenerateCode")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(doRegenerateCode)];
    [regenerateButton setTintColor:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:regenerateButton];
}


- (void)viewDidAppear:(BOOL)animated {
    [self.codeTextField becomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doRegenerateCode {
    
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
                                   //user.phone = self.phoneNumberServerRepresentation;
                                   [SVProgressHUD dismiss];
                                   [self performSegueWithIdentifier:@"" sender:self];
                                   [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
                                   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   
//                                   NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
//                                   if (loggedNumbers == nil) {
//                                       loggedNumbers = [NSMutableArray new];
//                                   }
//                                   if ([loggedNumbers containsObject:self.phoneNumberServerRepresentation] && !deviceAPNSid) {
//                                       [UIStoryboard showSWRevealController];
//                                   } else {
//                                       [self performSegueWithIdentifier:@"OTTutorial" sender:self];
//                                   }
                               } failure: ^(NSError *error) {
                                   [SVProgressHUD dismiss];
//                                   NSString *alertTitle = OTLocalizedString(@"error");
//                                   NSString *alertText = OTLocalizedString(@"connection_error");
//                                   NSString *buttonTitle = @"ok";
//                                   if ([[error.userInfo valueForKey:JSONResponseSerializerWithDataKey] isEqualToString:@"unauthorized"]) {
//                                       alertTitle = OTLocalizedString(@"tryAgain");
//                                       alertText = OTLocalizedString(@"invalidPhoneNumberOrCode");                                       buttonTitle = OTLocalizedString(@"tryAgain_short");
//                                       
//                                   }
//                                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle
//                                                                                                  message:alertText
//                                                                                           preferredStyle:UIAlertControllerStyleAlert];
//                                   UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:buttonTitle
//                                                                                           style:UIAlertActionStyleDefault
//                                                                                         handler:^(UIAlertAction * _Nonnull action) {}];
//                                   [alert addAction: defaultAction];
//                                   [self presentViewController:alert animated:YES completion:nil];
                                   
                               }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showKeyboard:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect viewFrame = self.scrollView.frame;
    CGFloat maxY = [UIScreen mainScreen].bounds.size.height - keyboardFrame.size.height;
    if (maxY < viewFrame.origin.y + viewFrame.size.height) {
        viewFrame.size.height = maxY - viewFrame.origin.y;
        self.scrollView.frame = viewFrame;
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - 1) animated:YES];
    }

}


@end
