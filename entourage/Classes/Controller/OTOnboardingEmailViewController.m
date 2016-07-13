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
#import "NSUserDefaults+OT.h"
#import "OTAuthService.h"

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
#if DEBUG //TARGET_IPHONE_SIMULATOR
    self.emailTextField.text = @"chip@tecknoworks.com";
#endif
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.emailTextField becomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)doContinue {
#if SKIP_ONBOARDING_REQUESTS
    [self performSegueWithIdentifier:@"EmailToNameSegue" sender:nil];
    return;
#endif
    NSString *email = self.emailTextField.text;
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    currentUser.email = email;

    [SVProgressHUD show];
    [[OTAuthService new] updateUserInformationWithUser:currentUser
                                               success:^(OTUser *user) {
                                                   [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
                                                   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];

                                                   [SVProgressHUD dismiss];
                                                   [self performSegueWithIdentifier:@"EmailToNameSegue" sender:self];
                                               }
                                               failure:^(NSError *error) {
                                                   NSDictionary *userInfo = [error userInfo];
                                                   NSString *errorMessage = @"";
                                                   NSDictionary *errorDictionary = [userInfo objectForKey:@"NSLocalizedDescription"];
                                                   if (errorDictionary) {
                                                       //NSString *code = [errorDictionary valueForKey:@"code"];
                                                       errorMessage = ((NSArray*)[errorDictionary valueForKey:@"message"]).firstObject;
                                                   }
                                                   
                                                   [SVProgressHUD showErrorWithStatus:errorMessage];
                                                   NSLog(@"ERR: something went wrong on onboarding user email: %@", error.description);
                                               }];

}

- (void)showKeyboard:(NSNotification*)notification {
    [self.scrollView scrollToBottomFromKeyboardNotification:notification
                                         andHeightContraint:self.heightContraint];
}

@end
