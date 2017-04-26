//
//  OTTourOptionsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 25/02/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourOptionsViewController.h"
#import "OTConsts.h"
#import "UIColor+entourage.h"


#define BUTTON_SIDE 48.0f
#define PADDING_VERTICAL 8.0f
#define PADDING_HORIZONTAL 16.0f
#define INITIAL_BOTTOM 82.0f

#define ACTION_LABEL_FRAME CGRectMake(0.0f, 0.0f, 230.0f, 21.0f)

@interface OTTourOptionsViewController ()

@property (nonatomic, weak) IBOutlet UILabel *createLabel;
@property (nonatomic, weak) IBOutlet UIButton *createButton;
//@property (nonatomic, weak) IBOutlet UILabel *poiLabel;
//@property (nonatomic, weak) IBOutlet UIButton *poiButton;


@end

@implementation OTTourOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.buttonIndex = 1;
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
    
    self.createLabel.hidden = YES;
    self.createButton.hidden = YES;

    [self addOptionWithIcon:@"report" andAction:@selector(doCreateEncounter:) withTranslation:NORTH_WEST];
    [self addOptionWithIcon:@"megaphone" andAction:@selector(doCreateDemande:) withTranslation:NORTH];
    [self addOptionWithIcon:@"heart" andAction:@selector(doCreateContribution:) withTranslation:NORTH_EAST];
}

/*******************************************************************************/

#pragma mark - Show options as a list

- (void)setupOptionsAsList {
    [super setupOptionsAsList];
    
    [self addOption:OTLocalizedString(@"create_encounter")
            atIndex:self.buttonIndex++
           withIcon:@"report"
          andAction:@selector(doCreateEncounter:)];
    
    [self addOption:OTLocalizedString(@"create_demande")
            atIndex:self.buttonIndex++
           withIcon:@"megaphone"
          andAction:@selector(doCreateDemande:)];
    
    [self addOption:OTLocalizedString(@"create_contribution")
            atIndex:self.buttonIndex++
           withIcon:@"heart"
          andAction:@selector(doCreateContribution:)];
    
    if(self.isPOIVisible)
        [self addOption:OTLocalizedString(@"propose_structure") atIndex:self.buttonIndex++ withIcon:@"house" andAction:@selector(proposeStructure:)];

    NSString *poiTitle = self.isPOIVisible ? @"map_options_hide_poi" : @"map_options_show_poi";
    [self addOption:OTLocalizedString(poiTitle)
            atIndex:self.buttonIndex++
           withIcon:@"solidarity"
          andAction:@selector(doTogglePOI:)];

}

@end
