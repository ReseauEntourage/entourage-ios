//
//  OTFeedItemJoinOptionsViewController.m
//  entourage
//
//  Created by sergiu buceac on 9/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

#import "OTFeedItemJoinOptionsViewController.h"
#import "UIView+entourage.h"
#import "OTFeedItemFactory.h"
#import "OTEntourage.h"
#import "OTConsts.h"
#import "OTTextView.h"
#import "OTTapViewBehavior.h"

@interface OTFeedItemJoinOptionsViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet OTTapViewBehavior *tapBehavior;

@end

@implementation OTFeedItemJoinOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tapBehavior initialize];
    self.greetingMessage.placeholder = OTLocalizedString(@"request_to_join_popup_placeholder");
    self.greetingMessage.editingPlaceholder = @"";
    self.greetingMessage.placeholderLargeColor = UIColor.grayColor;
    
    self.greetingMessage.forwardDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupGreetingLabelForItem];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doSendRequest {
    [OTLogger logEvent:@"SubmitJoinMessage"];
    NSString *message = self.greetingMessage.text;
    if (!message)
        message = @"";
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getJoiner] sendJoinMessage:message success:^(OTFeedItemJoiner *joiner) {
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    [self close:self];
}

- (IBAction)popupTapped:(id)sender {
    [self.greetingMessage resignFirstResponder];
}

#pragma mark - private methods

- (void)setupGreetingLabelForItem {
    if([self.feedItem isKindOfClass:[OTEntourage class]]){
        [self.greetingLabel setText:OTLocalizedString(@"join_entourage_greeting_lbl")];
    }
    else
        [self.greetingLabel setText:OTLocalizedString(@"join_tour_greeting_lbl")];
}

#pragma mark - - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [OTLogger logEvent:@"StartJoinMessage"];
}

@end
