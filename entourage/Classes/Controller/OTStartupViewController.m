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

@interface OTStartupViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation OTStartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController presentTransparentNavigationBar];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.title = @"";
    
    self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginButton.layer.borderWidth = 1.5f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSUserDefaults standardUserDefaults].temporaryUser = nil;
}

@end
