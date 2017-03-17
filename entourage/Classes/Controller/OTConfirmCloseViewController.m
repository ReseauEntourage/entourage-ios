//
//  OTConfirmCloseViewController.m
//  entourage
//
//  Created by veronica.gliga on 16/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTConfirmCloseViewController.h"
#import "OTNextStatusButtonBehavior.h"
#import "OTFeedItemFactory.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"

@implementation OTConfirmCloseViewController

#pragma mark - User interaction

- (IBAction)doSuccessfulClose {
    [OTLogger logEvent:@"SuccessfulClosePopup"];
    [self closeFeedItem];
}

- (IBAction)doBlockedClose {
    [OTLogger logEvent:@"BlockedClosePopup"];
    [self closeFeedItem];
}

- (IBAction)doHelpClose {
    [OTLogger logEvent:@"HelpRequestOnClosePopup"];
    [self closeFeedItem];
}

- (IBAction)doCancel {
    [OTLogger logEvent:@"CancelClosePopup"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

- (void)closeFeedItem {
    [OTLogger logEvent:@"CloseEntourageConfirm"];
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] closeWithSuccess:^(BOOL isTour) {
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:NO completion:^{
            if (self.delegate)
                [self.delegate closedFeedItem];
            if (self.closeDelegate)
                [self.closeDelegate feedItemClosed];
        }];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

@end
