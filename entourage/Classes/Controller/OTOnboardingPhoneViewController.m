//
//  OTOnboardingPhoneViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 06/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingPhoneViewController.h"
#import "IQKeyboardManager.h"
#import "UIView+entourage.h"

@interface OTOnboardingPhoneViewController ()

@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation OTOnboardingPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.phoneTextField.placeholder attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:.7] }];
    self.phoneTextField.attributedPlaceholder = str;
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.continueButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.phoneTextField becomeFirstResponder];
    //[self.scrollView setContentOffset:CGPointMake(0, self.scrollView.bounds.size.height) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height -= keyboardFrame.size.height;
    self.scrollView.frame = viewFrame;
    
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - 1) animated:YES];
    //[self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.contentSize.width - 1,self.scrollView.contentSize.height - 1, 1, 1) animated:YES];
}

@end
