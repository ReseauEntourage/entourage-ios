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
#import "OTAlertViewBehavior.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"
#import "OTAppConfiguration.h"

@interface OTMyEntouragesOptionsViewController ()

@property (strong, nonatomic) IBOutlet OTToggleGroupViewBehavior *toggleMaraude;
@property (strong, nonatomic) IBOutlet OTToggleGroupViewBehavior *toggleEncounter;
@property (strong, nonatomic) IBOutlet OTToggleGroupViewBehavior *toggleAction;
@property (strong, nonatomic) IBOutlet OTAlertViewBehavior *actionAlert;

@end

@implementation OTMyEntouragesOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.toggleMaraude initialize];
    [self.toggleEncounter initialize];
    [self.toggleAction initialize];
    [self.toggleMaraude toggle:NO];
    [self.toggleEncounter toggle:NO];
    [self.toggleAction toggle:NO];
    if(IS_PRO_USER && OTAppConfiguration.supportsTourFunctionality) {
        [self.toggleAction toggle:YES];
        if([OTOngoingTourService sharedInstance].isOngoing)
            [self.toggleEncounter toggle:YES];
        else
            [self.toggleMaraude toggle:YES];
    }
    __weak typeof(self) weakSelf = self;
    [OTAlertViewBehavior setupOngoingCreateEntourageWithAction:self.actionAlert];
    [self.actionAlert addAction:OTLocalizedString(@"encounter") handler: ^(UIAlertAction *action){
        if ([weakSelf.delegate respondsToSelector:@selector(createEncounter)])
            [weakSelf.delegate performSelector:@selector(createEncounter) withObject:nil];
    }];
    if(!IS_PRO_USER) {
        [self.delegate createAction];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)createAction {
    if ([OTOngoingTourService sharedInstance].isOngoing)
           [self.actionAlert presentOnViewController:self];
       else
           [self dismissViewControllerAnimated:YES completion:^() {
               [self.delegate createAction];
           }];
}

- (IBAction)createTour {
    [self dismissViewControllerAnimated:YES completion:^() {
        [self.delegate createTour];
    }];
}

- (IBAction)createEncounter {
    [self.delegate createEncounter];
}

- (IBAction)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
