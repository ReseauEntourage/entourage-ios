//
//  OTMapOptionsViewController.m
//  entourage
//
//  Created by Mihai Ionescu on 04/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMapOptionsViewController.h"
#import "OTConsts.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"
#import "OTAPIConsts.h"

@interface OTMapOptionsViewController ()

@property (nonatomic, weak) IBOutlet UIButton *createTourButton;
@property (nonatomic, weak) IBOutlet UILabel *createTourLabel;

@end

@implementation OTMapOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!CGPointEqualToPoint(self.fingerPoint, CGPointZero)) {
        [self setupOptionsAtFingerPoint];
    } else {
        [self setupOptionsAsList];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*******************************************************************************/

#pragma mark - Show options at fingerPoint

- (void)setupOptionsAtFingerPoint {
    [super setupOptionsAtFingerPoint];
    
    self.createTourLabel.hidden = YES;
    self.createTourButton.hidden = YES;

    if (IS_PRO_USER) {
        [self addOptionWithIcon:@"createMaraude" andAction:@selector(doCreateTour:) withTranslation:NORTH_WEST];
        [self addOptionWithIcon:@"megaphone" andAction:@selector(doCreateDemande:) withTranslation:NORTH];
        [self addOptionWithIcon:@"heart" andAction:@selector(doCreateContribution:) withTranslation:NORTH_EAST];
    } else {
        [self addOptionWithIcon:@"megaphone" andAction:@selector(doCreateDemande:) withTranslation:NORTH_WEST];
        [self addOptionWithIcon:@"heart" andAction:@selector(doCreateContribution:) withTranslation:NORTH_EAST];
    }
}

/*******************************************************************************/

#pragma mark - Show options as a list

- (void)setupOptionsAsList {
    [super setupOptionsAsList];
    
    if (IS_PRO_USER) {
        [self setupForProUser];
    } else {
        [self setupForPublicUser];
    }
}

- (void)setupForProUser {
    [self addOption:OTLocalizedString(@"create_tour") atIndex:self.buttonIndex++ withIcon:@"createMaraude" andAction:@selector(doCreateTour:)];
    [self setupForPublicUser];
}

- (void)setupForPublicUser {
    [self addOption:OTLocalizedString(@"create_action") atIndex:self.buttonIndex++ withIcon:@"heart" andAction:@selector(doCreateContribution:)];
    
    if(self.isPOIVisible)
        [self addOption:OTLocalizedString(@"propose_structure") atIndex:self.buttonIndex++ withIcon:@"house" andAction:@selector(proposeStructure:)];
}

@end
