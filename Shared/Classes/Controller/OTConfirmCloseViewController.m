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

@interface OTConfirmCloseViewController ()
@property (weak, nonatomic) IBOutlet UIView *ui_view_actions;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_confirm_action;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_fail_action;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_help_action;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_cancel_action;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_description_action;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_action;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_help_action;





@property (weak, nonatomic) IBOutlet UIView *ui_view_events;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_description_event;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_event;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_confirm_event;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_cancel_event;



@property (nonatomic, strong) IBOutlet OTMailSenderBehavior *sendMail;

@end

@implementation OTConfirmCloseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.feedItem isAction]) {
        [self.ui_view_events setHidden:YES];
        [self.ui_view_actions setHidden:NO];
    }
    else {
        [self.ui_view_events setHidden:NO];
        [self.ui_view_actions setHidden:YES];
    }
    
    [self setupViews];
}

-(void) setupViews {
    
    //Actions
    self.ui_label_title_action.text = OTLocalizedString(@"pop_validate_action_title");
    self.ui_label_description_action.text = OTLocalizedString(@"pop_validate_action_description");
    self.ui_label_help_action.text = OTLocalizedString(@"pop_validate_action_help");
    
    [self.ui_bt_cancel_action setTitle:OTLocalizedString(@"pop_validate_action_bt_cancel") forState:UIControlStateNormal];
    [self.ui_bt_confirm_action setTitle:OTLocalizedString(@"pop_validate_action_bt_validate") forState:UIControlStateNormal];
    [self.ui_bt_fail_action setTitle:OTLocalizedString(@"pop_validate_action_bt_fail") forState:UIControlStateNormal];
    [self.ui_bt_help_action setTitle:OTLocalizedString(@"pop_validate_action_bt_help") forState:UIControlStateNormal];
    
    //Events
    self.ui_label_title_event.text = OTLocalizedString(@"pop_validate_event_title");
    self.ui_label_description_event.text = OTLocalizedString(@"pop_validate_event_description");
    [self.ui_bt_cancel_event setTitle:OTLocalizedString(@"pop_validate_event_bt_cancel") forState:UIControlStateNormal];
    [self.ui_bt_confirm_event setTitle:OTLocalizedString(@"pop_validate_event_bt_validate") forState:UIControlStateNormal];
}


#pragma mark - User interaction

- (IBAction)doSuccessfulClose {
    [OTLogger logEvent:@"SuccessfulClosePopup"];
    [self closeFeedItemWithReason:OTCloseReasonSuccesClose];
}

- (IBAction)doBlockedClose {
    [OTLogger logEvent:@"BlockedClosePopup"];
    [self closeFeedItemWithReason:OTCloseReasonBlockedClose];
}

- (IBAction)doHelpClose {
    [OTLogger logEvent:@"HelpRequestOnClosePopup"];
    [self closeFeedItemWithReason:OTCloseReasonHelpClose];
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
