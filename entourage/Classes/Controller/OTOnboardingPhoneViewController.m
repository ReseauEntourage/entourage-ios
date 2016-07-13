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

@interface OTOnboardingPhoneViewController ()

@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation OTOnboardingPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"";
    
    [self.phoneTextField setupWithWhitePlaceholder];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.continueButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
#if DEBUG //TARGET_IPHONE_SIMULATOR
    self.phoneTextField.text = @"+40740884267";
#endif
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.phoneTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doContinue {
#if SKIP_ONBOARDING_REQUESTS 
    [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
    return;
#endif
    
    NSString *phone = self.phoneTextField.text;
    [SVProgressHUD show];
    [[OTOnboardingService new] setupNewUserWithPhone:phone
        success:^(OTUser *onboardUser) {
            [SVProgressHUD dismiss];
            onboardUser.phone = phone;
            [[NSUserDefaults standardUserDefaults] setCurrentUser:onboardUser];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
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
