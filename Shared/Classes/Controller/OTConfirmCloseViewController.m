//
//  OTConfirmCloseViewController.m
//  entourage
//
//  Created by veronica.gliga on 16/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "OTConfirmCloseViewController.h"
#import "OTNextStatusButtonBehavior.h"
#import "OTFeedItemFactory.h"
#import "OTConsts.h"
#import "OTMailSenderBehavior.h"
#import "OTCloseReason.h"
#import "Analytics_keys.h"

@interface OTConfirmCloseViewController ()

@property (weak, nonatomic) IBOutlet UIView *ui_view_actions2;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_confirm_action2;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_fail_action2;

@property (weak, nonatomic) IBOutlet UIButton *ui_bt_cancel_action2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_description_action2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_action2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title2_action2;

@property (weak, nonatomic) IBOutlet UIView *ui_view_events2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_description_event2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_event2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_bt_close_event2;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_close_event2;

@property (nonatomic, strong) IBOutlet OTMailSenderBehavior *sendMail;

@end

@implementation OTConfirmCloseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.feedItem isAction]) {
        [self.ui_view_events2 setHidden:YES];
        [self.ui_view_actions2 setHidden:NO];
    }
    else {
        [self.ui_view_events2 setHidden:NO];
        [self.ui_view_actions2 setHidden:YES];
    }
    
    [self setupViews];
    
    [OTLogger logEvent:Show_Pop_Close];
}

-(void) setupViews {
    
    //Actions
    self.ui_label_title_action2.text = OTLocalizedString(@"pop_validate_action_title");
    self.ui_label_description_action2.text = OTLocalizedString(@"pop_validate_action_description");
    self.ui_label_title2_action2.text = OTLocalizedString(@"pop_validate_action_title2");
    
    [self.ui_bt_cancel_action2 setTitle:OTLocalizedString(@"pop_validate_action_bt_cancel") forState:UIControlStateNormal];
    [self.ui_bt_confirm_action2 setTitle:OTLocalizedString(@"pop_validate_action_bt_validate") forState:UIControlStateNormal];
    [self.ui_bt_fail_action2 setTitle:OTLocalizedString(@"pop_validate_action_bt_fail") forState:UIControlStateNormal];

    [self.ui_bt_confirm_action2.layer setCornerRadius:5];
    [self.ui_bt_confirm_action2.layer setBorderWidth:1];
    [self.ui_bt_confirm_action2.layer setBorderColor:[[UIColor orangeColor] CGColor]];
    [self.ui_bt_fail_action2.layer setCornerRadius:5];
    [self.ui_bt_fail_action2.layer setBorderWidth:1];
    [self.ui_bt_fail_action2.layer setBorderColor:[[UIColor orangeColor] CGColor]];
    
    [self.ui_view_actions2.layer setCornerRadius:10];
    
    //Events
    self.ui_label_title_event2.text = OTLocalizedString(@"pop_validate_event_title2");
    self.ui_label_description_event2.text = OTLocalizedString(@"pop_validate_event_description2");

    [self.ui_label_bt_close_event2 setText:OTLocalizedString(@"pop_validate_event_bt_validate2")];
}


#pragma mark - User interaction

- (IBAction)doSuccessfulClose {
    [OTLogger logEvent:Action_Pop_Close_Success];
    [self closeFeedItemWithReason:OTCloseReasonSuccesClose];
}

- (IBAction)doBlockedClose {
    [OTLogger logEvent:Action_Pop_Close_Failed];
    [self closeFeedItemWithReason:OTCloseReasonBlockedClose];
}

- (IBAction)doCancel {
    [OTLogger logEvent:@"CancelClosePopup"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

- (void)closeFeedItemWithReason: (OTCloseReason) reason {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.closeDelegate) {
            [self.closeDelegate feedItemClosedWithReason: reason];
        }
    }];
}

@end
