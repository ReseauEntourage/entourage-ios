//
//  OTMyEntouragesOptionsViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMyEntouragesOptionsViewController.h"
#import "OTToggleGroupViewBehavior.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"

@interface OTMyEntouragesOptionsViewController ()

@property (strong, nonatomic) IBOutlet OTToggleGroupViewBehavior *toggleMaraude;

@end

@implementation OTMyEntouragesOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.toggleMaraude initialize];
    [self.toggleMaraude toggle:[[NSUserDefaults standardUserDefaults].currentUser.type isEqualToString:USER_TYPE_PRO]];
}

- (IBAction)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
