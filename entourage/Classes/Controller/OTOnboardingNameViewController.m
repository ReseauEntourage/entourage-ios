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
#import "NSError+message.h"

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
    
    [self.firstNameTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    [self.lastNameTextField setupWithPlaceholderColor:[UIColor appTextFieldPlaceholderColor]];
    
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
    NSString *firstName = self.firstNameTextField.text;
    NSString *lastName = self.lastNameTextField.text;
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    currentUser.firstName = firstName;
    currentUser.lastName = lastName;
    
    [SVProgressHUD show];
    [[OTAuthService new] updateUserInformationWithUser:currentUser
                                               success:^(OTUser *user) {
                                                   // TODO phone is not in response so need to restore it manually
                                                   user.phone = currentUser.phone;
                                                   [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
                                                   [SVProgressHUD dismiss];
                                                   [self performSegueWithIdentifier:ADD_PICTURE_SEGUE sender:self];
                                               }
                                               failure:^(NSError *error) {
                                                   [SVProgressHUD showErrorWithStatus:[error userUpdateMessage]];
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