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
#import "UIColor+entourage.h"

@interface OTConfirmCloseViewController()

@property (weak, nonatomic) IBOutlet UIView *ui_view_actions2;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_confirm_action2;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_fail_action2;

@property (weak, nonatomic) IBOutlet UIButton *ui_bt_validate_close;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_description_action2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_action2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title2_action2;

@property (weak, nonatomic) IBOutlet UIView *ui_view_ask_add_comment;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_add_comment_title;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_add_comment_desc;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_add_comment_yes;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_add_comment_no;


@property (weak, nonatomic) IBOutlet UIView *ui_view_events2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_description_event2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_title_event2;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_bt_close_event2;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_close_event2;

@property (weak, nonatomic) IBOutlet UIView *ui_view_add_comment;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_send_comment_title;
@property (weak, nonatomic) IBOutlet UIButton *ui_bt_send_comment;
@property (weak, nonatomic) IBOutlet UITextView *ui_tv_send_comment;



@property (nonatomic, strong) IBOutlet OTMailSenderBehavior *sendMail;

@property(nonatomic) BOOL isSuccess,isFail;

@end

@implementation OTConfirmCloseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isSuccess = NO;
    self.isFail = NO;
    
    [self.ui_view_add_comment setHidden:YES];
    [self.ui_view_ask_add_comment setHidden:YES];
    
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
    
    self.ui_bt_confirm_action2.layer.borderWidth = 1;
    self.ui_bt_confirm_action2.layer.borderColor = [[UIColor appOrangeColor] CGColor];
    self.ui_bt_fail_action2.layer.borderWidth = 1;
    self.ui_bt_fail_action2.layer.borderColor = [[UIColor appOrangeColor] CGColor];
    
    [self changeButtonValidateState];
}

-(void) setupViews {
    
    //Actions
    self.ui_label_title_action2.text = OTLocalizedString(@"pop_validate_action_title_new");
    self.ui_label_description_action2.text = OTLocalizedString(@"pop_validate_action_description_new");
    self.ui_label_title2_action2.text = OTLocalizedString(@"pop_validate_action_title2_new");
    
    [self.ui_bt_validate_close setTitle:OTLocalizedString(@"pop_validate_action_bt_validate_new").uppercaseString forState:UIControlStateNormal];
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
    
    //Pop add comment
    self.ui_label_add_comment_title.text = OTLocalizedString(@"pop_validate_action_add_comment_title");
    self.ui_label_add_comment_desc.text = OTLocalizedString(@"pop_validate_action_add_comment_desc");
    [self.ui_bt_add_comment_yes.layer setCornerRadius:5];
    [self.ui_bt_add_comment_yes.layer setBorderWidth:1];
    [self.ui_bt_add_comment_yes.layer setBorderColor:[[UIColor orangeColor] CGColor]];
    [self.ui_bt_add_comment_yes setTitle:OTLocalizedString(@"pop_validate_action_add_comment_yes") forState:UIControlStateNormal];
    [self.ui_bt_add_comment_no.layer setCornerRadius:5];
    [self.ui_bt_add_comment_no.layer setBorderWidth:1];
    [self.ui_bt_add_comment_no.layer setBorderColor:[[UIColor orangeColor] CGColor]];
    [self.ui_bt_add_comment_no setTitle:OTLocalizedString(@"pop_validate_action_add_comment_no") forState:UIControlStateNormal];
    
    //Pop send comment
    self.ui_tv_send_comment.layer.borderWidth = 1;
    self.ui_tv_send_comment.layer.borderColor = [[UIColor colorWithRed:216 / 255.0 green:216 / 255.0 blue:216 / 255.0 alpha:1.0]CGColor];
    self.ui_tv_send_comment.layer.cornerRadius = 5;
    self.ui_label_send_comment_title.text = OTLocalizedString(@"pop_validate_action_add_comment_send_title");
    [self.ui_bt_send_comment setTitle:OTLocalizedString(@"pop_validate_action_add_comment_send_button") forState:UIControlStateNormal];
    
    self.ui_tv_send_comment.text = OTLocalizedString(@"pop_validate_action_add_comment_send_placeholder");
    [self.ui_tv_send_comment setTextColor:[UIColor lightGrayColor]];
    
}


#pragma mark - User interaction

- (IBAction)doSuccessfulClose {
    [OTLogger logEvent:Action_Pop_Close_Success];
    [self closeFeedItemWithReason:OTCloseReasonSuccesClose andComment:@""];
}

- (IBAction)doBlockedClose {
    [OTLogger logEvent:Action_Pop_Close_Failed];
    [self closeFeedItemWithReason:OTCloseReasonBlockedClose andComment:@""];
}

- (IBAction)doCancel {
    [OTLogger logEvent:@"CancelClosePopup"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)action_select_success:(id)sender {
    self.isFail = NO;
    self.isSuccess = !self.isSuccess;
    [self changeButtonValidateState];
}

- (IBAction)action_select_fail:(id)sender {
    self.isFail = !self.isFail;
    self.isSuccess = NO;
    [self changeButtonValidateState];
}

- (IBAction)action_valid_close:(id)sender {
    [self.ui_view_ask_add_comment setHidden:NO];
    [self.ui_view_actions2 setHidden: YES];
}

- (IBAction)action_add_comment:(id)sender {
    self.ui_tv_send_comment.text = OTLocalizedString(@"pop_validate_action_add_comment_send_placeholder");
    [self.ui_tv_send_comment setTextColor:[UIColor lightGrayColor]];
    [self validateMessageAndChangeButtonSend];
    
    [self.ui_view_add_comment setHidden:NO];
    [self.ui_view_ask_add_comment setHidden:YES];
}

- (IBAction)action_no_comment:(id)sender {
    if (self.isSuccess) {
        [self doSuccessfulClose];
    }
    else {
        [self doBlockedClose];
    }
}

- (IBAction)action_close_send_comment:(id)sender {
    if (self.isSuccess) {
        [self doSuccessfulClose];
    }
    else {
        [self doBlockedClose];
    }
}

- (IBAction)action_send_comment:(id)sender {
    
    if (self.ui_tv_send_comment.text.length == 0) {
        return;
    }
    
    if (self.isSuccess) {
        [OTLogger logEvent:Action_Pop_Close_Success];
        [self closeFeedItemWithReason:OTCloseReasonSuccesClose andComment:self.ui_tv_send_comment.text];
    }
    else {
        [OTLogger logEvent:Action_Pop_Close_Failed];
        [self closeFeedItemWithReason:OTCloseReasonBlockedClose andComment:self.ui_tv_send_comment.text];
    }
}

- (IBAction)action_tap_close_kb:(id)sender {
    [self.ui_tv_send_comment resignFirstResponder];
}

-(void) changeButtonValidateState {
    CGFloat alpha = 1;
    if (self.isSuccess || self.isFail) {
        [self.ui_bt_validate_close setEnabled:YES];
    }
    else {
        [self.ui_bt_validate_close setEnabled:NO];
        alpha = 0.5;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ui_bt_validate_close.alpha = alpha;
        if (self.isSuccess) {
            self.ui_bt_confirm_action2.backgroundColor = [UIColor appOrangeTransColor];
            self.ui_bt_fail_action2.backgroundColor = [UIColor whiteColor];
        }
        else if(self.isFail) {
            self.ui_bt_fail_action2.backgroundColor = [UIColor appOrangeTransColor];
            self.ui_bt_confirm_action2.backgroundColor = [UIColor whiteColor];
        }
        else {
            self.ui_bt_confirm_action2.backgroundColor = [UIColor whiteColor];
            self.ui_bt_fail_action2.backgroundColor = [UIColor whiteColor];
        }
    });
}

-(void) validateMessageAndChangeButtonSend {
    if (self.ui_tv_send_comment.text.length > 0 && ![self.ui_tv_send_comment.text isEqualToString:OTLocalizedString(@"pop_validate_action_add_comment_send_placeholder")]) {
        [self.ui_bt_send_comment setEnabled:YES];
        self.ui_bt_send_comment.alpha = 1.0;
    }
    else {
        [self.ui_bt_send_comment setEnabled:NO];
        self.ui_bt_send_comment.alpha = 0.2;
    }
}

#pragma mark - private methods

- (void)closeFeedItemWithReason: (OTCloseReason) reason andComment:(NSString*) comment {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.closeDelegate) {
            [self.closeDelegate feedItemClosedWithReason: reason andComment:comment];
        }
    }];
}

#pragma mark - UITextViewDelegate -
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (textView.text.length > 0 && [textView.text isEqualToString:OTLocalizedString(@"pop_validate_action_add_comment_send_placeholder")]) {
        self.ui_tv_send_comment.text = @"";
        [self.ui_tv_send_comment setTextColor:[UIColor blackColor]];
    }
    [self validateMessageAndChangeButtonSend];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.ui_tv_send_comment.text = OTLocalizedString(@"pop_validate_action_add_comment_send_placeholder");
        [self.ui_tv_send_comment setTextColor:[UIColor lightGrayColor]];
    }
    [self validateMessageAndChangeButtonSend];
}

@end
