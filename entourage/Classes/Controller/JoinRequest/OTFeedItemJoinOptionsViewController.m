//
//  OTFeedItemJoinOptionsViewController.m
//  entourage
//
//  Created by sergiu buceac on 9/12/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemJoinOptionsViewController.h"
#import "UIView+entourage.h"
#import "OTFeedItemFactory.h"
#import "SVProgressHUD.h"
#import "OTEntourage.h"
#import "OTConsts.h"

@interface OTFeedItemJoinOptionsViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *greetingLabel;
@property (nonatomic, weak) IBOutlet UITextView *greetingMessage;

@end

@implementation OTFeedItemJoinOptionsViewController

//- (IBAction)addMessage:(id)sender {
//    [self.joinDelegate addMessage];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGreetingLabelForItem];
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
