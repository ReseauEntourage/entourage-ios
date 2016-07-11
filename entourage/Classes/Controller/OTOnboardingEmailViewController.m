//
//  OTOnboardingEmailViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 08/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingEmailViewController.h"

#import "IQKeyboardManager.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"
#import "UIScrollView+entourage.h"

@interface OTOnboardingEmailViewController ()

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UIButton *validateButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation OTOnboardingEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"";
    [self.emailTextField setupWithWhitePlaceholder];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.validateButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.emailTextField becomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)doContinue {
    NSString *phone = self.emailTextField.text;
    
    [self performSegueWithIdentifier:@"EmailToNameSegue" sender:self];
    return;
    [SVProgressHUD show];
    

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
    //[self.scrollView scrollToBottomFromKeyboardNotification:notification];
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint];
}

@end
