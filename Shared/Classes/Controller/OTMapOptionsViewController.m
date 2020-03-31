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
#import "OTAppConfiguration.h"
#import "OTSafariService.h"
#import "OTHTTPRequestManager.h"

@interface OTMapOptionsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *ui_label_title;
@property (nonatomic, weak) IBOutlet UIButton *createTourButton;
@property (nonatomic, weak) IBOutlet UILabel *createTourLabel;
@property (weak, nonatomic) IBOutlet UIButton *ui_button_show_web;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_button;

@end

@implementation OTMapOptionsViewController

- (void)viewDidLoad {
    self.isNewOptions = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!CGPointEqualToPoint(self.fingerPoint, CGPointZero) &&
        [OTAppConfiguration supportsAddingActionsFromMapOnLongPress]) {
        [self setupOptionsAtFingerPoint];
    } else {
        [self setupOptionsAsList];
    }
    
    self.ui_button_show_web.layer.borderWidth = 1;
    self.ui_button_show_web.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [self.ui_label_title setText:OTLocalizedString(@"agir_new_title")];
    [self.ui_label_title_button setText:OTLocalizedString(@"agir_new_button_title")];
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

    if (IS_PRO_USER && OTAppConfiguration.supportsTourFunctionality) {
        [self addOptionWithIcon:@"createMaraude" andAction:@selector(doCreateTour:) withTranslation:NORTH_WEST];
        [self addOptionWithIcon:@"heart" andAction:@selector(doCreateAction:) withTranslation:NORTH_EAST];
        [self addOptionWithIcon:@"addEvent" andAction:@selector(doCreateEvent:) withTranslation:SOUTH_EAST];
    } else {
        [self addOptionWithIcon:@"heart" andAction:@selector(doCreateAction:) withTranslation:NORTH_WEST];
        [self addOptionWithIcon:@"addEvent" andAction:@selector(doCreateEvent:) withTranslation:SOUTH_EAST];
        [self addOptionWithIcon:@"house"
                 applyTintColor:NO
                      andAction:@selector(proposeStructure:)
                withTranslation:NORTH_EAST];
    }
}

/*******************************************************************************/

#pragma mark - Show options as a list

- (void)setupOptionsAsList {
    [super setupOptionsAsList];
    
    if (IS_PRO_USER && OTAppConfiguration.supportsTourFunctionality) {
        [self setupForProUser];
    } else {
        [self setupForPublicUser];
    }
}

- (void)setupForProUser {
    [self addOption:OTLocalizedString(@"create_tour")
      atIndex:self.buttonIndex++ withIconWithoutBG:@"agir_icn_maraude"
    andAction:@selector(doCreateEvent:)];
    [self setupForPublicUser];
}

- (void)setupForPublicUser {
    [self addOption:OTLocalizedString(@"create_event")
      atIndex:self.buttonIndex++ withIconWithoutBG:@"agir_icn_event"
    andAction:@selector(doCreateEvent:)];
    
    [self addOption:OTLocalizedString(@"create_proposer_don")
      atIndex:self.buttonIndex++ withIconWithoutBG:@"agir_icn_don"
    andAction:@selector(doCreateActionGift:)];
    
    [self addOption:OTLocalizedString(@"create_demande_aide")
            atIndex:self.buttonIndex++ withIconWithoutBG:@"agir_icn_aide"
          andAction:@selector(doCreateActionHelp:)];
}

//MARK: IBactions
- (IBAction)action_close_pop:(id)sender {
    [OTAppState hideTabBar:NO];
    if ([self.optionsDelegate respondsToSelector:@selector(dismissOptions)]) {
        [self.optionsDelegate performSelector:@selector(dismissOptions) withObject:nil];
    }
}
- (IBAction)action_show_help:(id)sender {
    
    NSURL * url = [OTSafariService redirectUrlWithIdentifier:@"pedagogic-content"];
    
    [OTSafariService launchInAppBrowserWithUrl:url viewController:self.navigationController];
}

@end
