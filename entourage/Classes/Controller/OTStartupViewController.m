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
@property (weak, nonatomic) IBOutlet UIButton *registerButton;


@end

@implementation OTStartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.registerButton setupRoundedCorners];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
//    self.navigationController.navigationBarHidden = YES;
//    UINavigationBar.appearance.barTintColor = [UIColor clearColor];
//    UINavigationBar.appearance.backgroundColor = [UIColor clearColor];
    [self.navigationController presentTransparentNavigationBar];

    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    self.title = @"";
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
//    UINavigationBar.appearance.barTintColor = [UIColor whiteColor];
//    UINavigationBar.appearance.backgroundColor = [UIColor whiteColor];
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
- (IBAction)registerTap:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"info"
                                                                    message:@"to be implemented"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                     }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:NULL];
}

@end
