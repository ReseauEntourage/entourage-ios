//
//  OTAskMoreViewController.m
//  entourage
//
//  Created by Nicolas Telera on 08/12/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTAskMoreViewController.h"

// Service
#import "OTAuthService.h"

// Helper
#import "NSString+Validators.h"
#import "NSDictionary+Parsing.h"

// View
#import "SVProgressHUD.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTAskMoreViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *subscribeButton;

@end

@implementation OTAskMoreViewController

/********************************************************************************/
#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DÉCOUVREZ ENTOURAGE";
    self.navigationController.navigationBarHidden = NO;
    [self setupCloseModal];
}

/********************************************************************************/
#pragma mark - Actions

- (IBAction)closeModal:(id)sender {
    if ([self.delegate respondsToSelector:@selector(hideBlurEffect)]) {
        [self.delegate hideBlurEffect];
    }
    [self.emailField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openFacebook:(id)sender {
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/622067231241188"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://facebook.com/EntourageReseauCivique"]];
    }
}

- (IBAction)openTwitter:(id)sender {
    NSURL *twitterURL = [NSURL URLWithString:@"twitter://user?screen_name=r_entour"];
    if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
        [[UIApplication sharedApplication] openURL:twitterURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/r_entour"]];
    }
}

- (IBAction)subscribeToNewsletter:(id)sender {
    if (![self.emailField.text isEqualToString:@""] && [self.emailField.text isValidEmail]) {
        [SVProgressHUD show];
        [[OTAuthService new] subscribeToNewsletterWithEmail:self.emailField.text
                                                    success:^(BOOL active) {
                                                        NSLog(active ? @"Newsletter subscription success" : @"Newsletter subscription failure");
                                                        if (active) {
                                                            [SVProgressHUD showSuccessWithStatus:@"Demande envoyée"];
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                        }
                                                    } failure:^(NSError *error) {
                                                        [SVProgressHUD showErrorWithStatus:@"Demande non envoyée"];
                                                        NSLog(@"%@", error);
                                                    }];
    } else {
        [[[UIAlertView alloc]
          initWithTitle:@"Demande impossible"
          message:@"Veuillez renseigner une adresse email valide"
          delegate:nil
          cancelButtonTitle:nil
          otherButtonTitles:@"ok",
          nil] show];
    }
}

#pragma mark - Private
- (void)setupCloseModal {
    UIImage *menuImage = [[UIImage imageNamed:@"close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    [menuButton setImage:menuImage];
    [menuButton setTarget:self];
    [menuButton setAction:@selector(closeModal:)];
    
    [self.navigationItem setLeftBarButtonItem:menuButton];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

}

@end
