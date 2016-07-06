//
//  OTStartupViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTStartupViewController.h"
#import "UIView+entourage.h"

//Helper
#import "UINavigationController+entourage.h"


@interface OTStartupViewController ()
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@end

@implementation OTStartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.registerButton setupHalfRoundedCorners];
    [self.loginButton setupHalfRoundedCorners];
    self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginButton.layer.borderWidth = 1.5f;
    
    [self.facebookButton setupHalfRoundedCorners];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    //self.navigationController.navigationBarHidden = NO;
//    UINavigationBar.appearance.barTintColor = [UIColor clearColor];
//    UINavigationBar.appearance.backgroundColor = [UIColor clearColor];
    [self.navigationController presentTransparentNavigationBar];

    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    self.title = @"";
    //UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
    //UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];
     [self.navigationController presentTransparentNavigationBar];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
