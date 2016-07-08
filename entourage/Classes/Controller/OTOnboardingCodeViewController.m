//
//  OTOnboardingCodeViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 07/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingCodeViewController.h"
#import "IQKeyboardManager.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"

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
    NSString *phone = self.codeTextField.text;
    [SVProgressHUD show];
    return;
    [[OTOnboardingService new] setupNewUserWithPhone:phone
                                             success:^(OTUser *onboardUser) {
                                                 [SVProgressHUD dismiss];
                                             } failure:^(NSError *error) {
                                                 NSDictionary *userInfo = [error userInfo];
                                                 NSString *errorMessage = @"";
                                                 NSDictionary *errorDictionary = [userInfo objectForKey:@"NSLocalizedDescription"];
                                                 if (errorDictionary) {
                                                     //NSString *code = [errorDictionary valueForKey:@"code"];
                                                     errorMessage = ((NSArray*)[errorDictionary valueForKey:@"message"]).firstObject;
                                                 }
                                                 
                                                 [SVProgressHUD showErrorWithStatus:errorMessage];
                                                 NSLog(@"ERR: something went wrong on onboarding user phone: %@", error.description);
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
    viewFrame.size.height = maxY - viewFrame.origin.y;
    self.scrollView.frame = viewFrame;
    
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - 1) animated:YES];
}


@end
