//
//  OTTutorial4ViewController.m
//  entourage
//
//  Created by sergiu buceac on 2/20/17.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTTutorial4ViewController.h"

@interface OTTutorial4ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *btnSelectAssociation;
@property (nonatomic, weak) IBOutlet UIButton *btnClose;

@end

@implementation OTTutorial4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.btnSelectAssociation setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    [self.btnClose setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 20)];
    self.btnClose.layer.borderColor = self.btnClose.currentTitleColor.CGColor;
}

- (IBAction)showPartnerSelection:(id)sender {
    UIStoryboard *userProfileStoryboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    UIViewController *selectAssociationController = [userProfileStoryboard instantiateViewControllerWithIdentifier:@"SelectAssociation"];
    [self.navigationController pushViewController:selectAssociationController animated:YES];
}

- (IBAction)close:(id)sender {
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
}

@end
