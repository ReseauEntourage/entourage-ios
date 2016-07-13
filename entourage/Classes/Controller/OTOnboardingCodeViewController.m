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
    
    [self.codeTextField setupWithWhitePlaceholder];
    
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
#if TARGET_IPHONE_SIMULATOR == 1
    [self performSegueWithIdentifier:@"CodeToEmailSegue" sender:nil];
    return;
#endif
    
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
