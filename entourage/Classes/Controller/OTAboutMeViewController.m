//
//  OTAboutMeViewController.m
//  entourage
//
//  Created by veronica.gliga on 26/10/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAboutMeViewController.h"
#import "OTTapViewBehavior.h"
#import "SVProgressHUD.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "OTAuthService.h"
#import "OTConsts.h"

@interface OTAboutMeViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet OTTapViewBehavior *tapBehavior;

@end

@implementation OTAboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doSendDescription {
    
    NSString *aboutMessage = self.aboutMeMessage.text;
    if (!aboutMessage)
        aboutMessage = @"";
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    currentUser.about = aboutMessage;
    [SVProgressHUD show];
    
    [[OTAuthService new] updateUserInformationWithUser:currentUser
                                               success:^(OTUser *user) {
                                                   // TODO phone is not in response so need to restore it manually
                                                   user.phone = currentUser.phone;
                                                   [NSUserDefaults standardUserDefaults].currentUser = user;
                                                   [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_tours_only"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   [SVProgressHUD dismiss];
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationAboutMeUpdated object:nil userInfo:nil];

                                               }
                                               failure:^(NSError *error) {
                                                   [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                   NSLog(@"ERR: something went wrong on onboarding user email: %@", error.description);
                                               }];
    
    [self close:self];
}

@end
