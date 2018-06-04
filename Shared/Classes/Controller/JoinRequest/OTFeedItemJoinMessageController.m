//
//  OTFeedItemJoinMessageController.m
//  entourage
//
//  Created by Ciprian Habuc on 01/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "OTFeedItemJoinMessageController.h"
#import "OTTourService.h"
#import "OTEntourageService.h"
#import "OTTour.h"
#import "OTEntourage.h"
#import "OTFeedItemFactory.h"

#import "OTConsts.h"

@interface OTFeedItemJoinMessageController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *greetingLabel;
@property (nonatomic, weak) IBOutlet UITextView *greetingMessage;

@end

@implementation OTFeedItemJoinMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupUI {
    NSDictionary *lightAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightLight]};
    NSDictionary *mediumAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17 weight:UIFontWeightMedium]};
    NSAttributedString *merciAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@!\n\n", OTLocalizedString(@"thanks").uppercaseString] attributes:mediumAttrs];
    NSAttributedString *cetteTourAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", OTLocalizedString(@"tour_join_intro")] attributes:lightAttrs];
    NSAttributedString *messageAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", OTLocalizedString(@"tour_join_message")] attributes:mediumAttrs];
    
    NSMutableAttributedString *greetingAttrString = merciAttrString.mutableCopy;
    [greetingAttrString appendAttributedString:cetteTourAttrString];
    [greetingAttrString appendAttributedString:messageAttrString];

    [self.greetingLabel setAttributedText:greetingAttrString];
}

- (IBAction)close {
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
    [self close];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [OTLogger logEvent:@"StartJoinMessage"];
}

@end
