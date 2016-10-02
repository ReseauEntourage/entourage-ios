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
#import "OTOngoingTourService.h"

@interface OTMyEntouragesOptionsViewController ()

@property (strong, nonatomic) IBOutlet OTToggleGroupViewBehavior *toggleMaraude;
@property (strong, nonatomic) IBOutlet OTToggleGroupViewBehavior *toggleEncounter;

@end

@implementation OTMyEntouragesOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.toggleMaraude initialize];
    [self.toggleEncounter initialize];
    [self.toggleMaraude toggle:NO];
    [self.toggleEncounter toggle:NO];
    if([[NSUserDefaults standardUserDefaults].currentUser.type isEqualToString:USER_TYPE_PRO]) {
        if([OTOngoingTourService sharedInstance].isOngoing)
            [self.toggleEncounter toggle:YES];
        else
            [self.toggleMaraude toggle:YES];
    }
}

- (IBAction)createDemand {
    [self dismissViewControllerAnimated:YES completion:^() {
        [self.delegate createDemand];
    }];
}

- (IBAction)createContribution {
    [self dismissViewControllerAnimated:YES completion:^() {
        [self.delegate createContribution];
    }];
}

- (IBAction)createTour {
    [self dismissViewControllerAnimated:YES completion:^() {
        [self.delegate createTour];
    }];
}

- (IBAction)createEncounter {
    ge[self.delegate createEncounter];
}

- (IBAction)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
