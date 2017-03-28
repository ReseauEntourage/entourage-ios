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
#import "OTMailSenderBehavior.h"
#import "OTCloseReason.h"

@interface OTConfirmCloseViewController ()

@property (nonatomic, strong) IBOutlet OTMailSenderBehavior *sendMail;

@end

@implementation OTConfirmCloseViewController

#pragma mark - User interaction

- (IBAction)doSuccessfulClose {
    [OTLogger logEvent:@"SuccessfulClosePopup"];
    [self closeFeedItemWithReason:SuccesClose];
}

- (IBAction)doBlockedClose {
    [OTLogger logEvent:@"BlockedClosePopup"];
    [self closeFeedItemWithReason:BlockedClose];
}

- (IBAction)doHelpClose {
    [OTLogger logEvent:@"HelpRequestOnClosePopup"];
    [self closeFeedItemWithReason:HelpClose];
}

- (IBAction)doCancel {
    [OTLogger logEvent:@"CancelClosePopup"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

- (void)closeFeedItemWithReason: (OTCloseReason) reason {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.closeDelegate)
            [self.closeDelegate feedItemClosedWithReason: reason];
    }];
}

@end
