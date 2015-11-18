//
//  OTUserViewController.m
//  entourage
//
//  Created by OCTO-NTE on 17/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTUserViewController.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTUserViewController ()

@property (nonatomic, strong) OTUser *currentUser;

@property (nonatomic, weak) IBOutlet UIButton *backButton;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UILabel *toursLabel;
@property (nonatomic, weak) IBOutlet UILabel *encountersLabel;
@property (nonatomic, weak) IBOutlet UILabel *organizationLabel;

@end

@implementation OTUserViewController

/********************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    self.currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [self.currentUser firstName], [self.currentUser lastName]];
    self.emailLabel.text = [NSString stringWithFormat:@"%@", [self.currentUser email]];
    self.toursLabel.text = [NSString stringWithFormat:@"%@ maraudes réalisées", [self.currentUser tourCount]];
    self.encountersLabel.text = [NSString stringWithFormat:@"%@ personnes rencontrées", [self.currentUser encounterCount]];
    self.organizationLabel.text = [NSString stringWithFormat:@"%@", [self.currentUser.organization name]];
}

- (IBAction)closeProfile:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
