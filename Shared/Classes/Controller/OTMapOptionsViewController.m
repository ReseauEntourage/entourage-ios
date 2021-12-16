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
#import "Analytics_keys.h"

@interface OTMapOptionsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *ui_label_title;
@property (nonatomic, weak) IBOutlet UIButton *createTourButton;
@property (weak, nonatomic) IBOutlet UIButton *ui_button_close;
@property (nonatomic, weak) IBOutlet UILabel *createTourLabel;
@property (weak, nonatomic) IBOutlet UIButton *ui_button_show_web;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_button;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_button_close;
@property (weak, nonatomic) IBOutlet UIImageView *ui_iv_agir;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_constraint_image_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_constraint_image_top;

@end

@implementation OTMapOptionsViewController

- (void)viewDidLoad {
    self.isNewOptions = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _ui_button_close.accessibilityLabel = @"fermer";
    
    if (!CGPointEqualToPoint(self.fingerPoint, CGPointZero) &&
        [OTAppConfiguration supportsAddingActionsFromMapOnLongPress]) {
        [self setupOptionsAtFingerPoint];
    } else {
        [self setupOptionsAsList];
    }
    
    self.ui_button_show_web.layer.borderWidth = 1;
    self.ui_button_show_web.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [self.ui_label_title setText:OTLocalizedString(@"agir_new_title")];
    
    [self.ui_label_title_button_close setText:OTLocalizedString(@"cancel")];
    
    [OTLogger logEvent:View_Plus_Screen];
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
    andAction:@selector(doCreateTour:) andSubtitle:@""];
    [self setupForPublicUser];
    
    if (UIScreen.mainScreen.bounds.size.height <= 568) {
        self.ui_constraint_image_height.constant = 70;
        self.ui_constraint_image_top.constant = 10;
        [self.view layoutIfNeeded];
    }
    else if (UIScreen.mainScreen.bounds.size.height <= 667) {
        self.ui_constraint_image_height.constant = 100;
        self.ui_constraint_image_top.constant = 20;
        [self.view layoutIfNeeded];
    }
    
}

- (void)setupForPublicUser {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    NSString *buttonFaq = @"";
    
    if ([currentUser.goal isEqualToString:@"organization"]) {
        buttonFaq = @"agir_new_button_title_asso";
    }
    else {
        buttonFaq = currentUser.isUserTypeAlone ? @"agir_new_button_title_alone" : @"agir_new_button_title";
    }
    
    [self.ui_label_title_button setText:OTLocalizedString(buttonFaq)];
    self.ui_button_show_web.accessibilityLabel = OTLocalizedString(buttonFaq);
    
    bool showAddEvent = [[[NSUserDefaults standardUserDefaults]currentUser] isCreateEventActive];
    if (showAddEvent) {
        [self addOption:OTLocalizedString(@"create_event")
          atIndex:self.buttonIndex++ withIconWithoutBG:@"agir_icn_event"
        andAction:@selector(doCreateEvent:) andSubtitle:OTLocalizedString(@"agir_subtitle_event")];
    }
    
    
    [self addOption:OTLocalizedString(@"create_proposer_don")
      atIndex:self.buttonIndex++ withIconWithoutBG:@"agir_icn_don"
    andAction:@selector(doCreateActionGift:) andSubtitle:@""];
    
    [self addOption:OTLocalizedString(@"create_demande_aide")
            atIndex:self.buttonIndex++ withIconWithoutBG:@"agir_icn_aide"
          andAction:@selector(doCreateActionHelp:) andSubtitle:@""];
    
    NSString *subOndes = currentUser.isUserTypeAlone ? @"agir_bonnes_ondes_alone" : @"agir_bonnes_ondes_others";
     
    [self addOption:OTLocalizedString(@"agir_title_bonnes_ondes")
      atIndex:self.buttonIndex++ withIconWithoutBG:@"icn_agir_ondes"
    andAction:@selector(doShowFormOndes:) andSubtitle:OTLocalizedString(subOndes)];
}

//MARK: IBactions
- (IBAction)action_close_pop:(id)sender {
    [OTLogger logEvent:Action_Plus_BackPressed];
    [OTAppState hideTabBar:NO];
    if ([self.optionsDelegate respondsToSelector:@selector(dismissOptions)]) {
        [self.optionsDelegate performSelector:@selector(dismissOptions) withObject:nil];
    }
}
- (IBAction)action_show_help:(id)sender {
    [OTLogger logEvent:Action_Plus_Help];
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    NSString *buttonFaq = @"";
    if ([currentUser.goal isEqualToString:@"organization"]) {
        buttonFaq = SLUG_ACTION_ASSO;
    }
    else {
        buttonFaq = currentUser.isUserTypeAlone ? SLUG_ACTION_FAQ : SLUG_ACTION_SCB;
    }
    NSURL * url = [OTSafariService redirectUrlWithIdentifier:buttonFaq];
    
    [OTSafariService launchInAppBrowserWithUrl:url viewController:self];
}

-(IBAction)doShowFormOndes:(id)sender {
    [OTLogger logEvent:Action_Plus_GoodWaves];
    NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS,GOOD_WAVES_LINK_ID,TOKEN];
       NSString *urlForm = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
    
    [OTSafariService launchInAppBrowserWithUrlString:urlForm viewController:self];
}

@end
