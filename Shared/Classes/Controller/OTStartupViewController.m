//
//  OTStartupViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTStartupViewController.h"
#import "UIView+entourage.h"
#import "NSUserDefaults+OT.h"
#import "UINavigationController+entourage.h"
#import "OTAppConfiguration.h"
#import "entourage-Swift.h"

@interface OTStartupViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *betaButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation OTStartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController presentTransparentNavigationBar];
    
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].primaryNavigationBarTintColor;
    
    [self.registerButton setTitleColor:[ApplicationTheme shared].backgroundThemeColor forState:UIControlStateNormal];
    
    self.title = @"";
    
    self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginButton.layer.borderWidth = 1.5f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [OTLogger logEvent:@"Screen01SplashView"];
    [NSUserDefaults standardUserDefaults].temporaryUser = nil;
    
    self.betaButton.hidden = NO;
    
    NSString *title = [NSString stringWithFormat:@"Vous êtes sur %@.\n(Tapez pour changer)", [[OTAppConfiguration sharedInstance] environmentConfiguration].environmentName];
    self.betaButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.betaButton.titleLabel.numberOfLines = 2;
    [self.betaButton setTitle:title forState:UIControlStateNormal];
    self.betaButton.hidden = YES;
}

-(IBAction)showSignUp:(id)sender {
    [OTLogger logEvent:@"SplashSignUp"];
    [self performSegueWithIdentifier:@"SignUpSegue" sender:nil];
}

-(IBAction)showLogin:(id)sender {
    [OTLogger logEvent:@"SplashLogIn"];
    [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
}

@end
