//
//  OTOnboardingNameViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 08/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingNameViewController.h"

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
#import "OTOnboardingPictureViewController.h"

#define ADD_PICTURE_SEGUE @"AddPictureSegue"

@interface OTOnboardingNameViewController ()

@property (nonatomic, weak) IBOutlet UITextField *firstNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastNameTextField;
@property (nonatomic, weak) IBOutlet UIButton *validateButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation OTOnboardingNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"";
    
    [self.firstNameTextField setupWithWhitePlaceholder];
    [self.lastNameTextField setupWithWhitePlaceholder];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.validateButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.firstNameTextField becomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)doContinue {
#if TARGET_IPHONE_SIMULATOR == 1
    [self performSegueWithIdentifier:ADD_PICTURE_SEGUE sender:nil];
    return;
#endif
    NSString *firstName = self.firstNameTextField.text;
    NSString *lastName = self.lastNameTextField.text;
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    currentUser.firstName = firstName;
    currentUser.lastName = lastName;
    
    [SVProgressHUD show];
    [[OTAuthService new] updateUserInformationWithUser:currentUser
                                               success:^(OTUser *user) {
                                                   [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   
                                                   [SVProgressHUD dismiss];
                                                   [self performSegueWithIdentifier:ADD_PICTURE_SEGUE sender:self];
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
                                                   NSLog(@"ERR: something went wrong on onboarding user name: %@", error.description);
                                               }];

}

- (void)showKeyboard:(NSNotification*)notification {
    //[self.scrollView scrollToBottomFromKeyboardNotification:notification];
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ADD_PICTURE_SEGUE]) {
        OTOnboardingPictureViewController *controller = (OTOnboardingPictureViewController*)[segue destinationViewController];
        controller.isOnboarding = YES;
        // TODO set delegate for action after picture is ok
        //controller.delegate = self;
    }
}

@end