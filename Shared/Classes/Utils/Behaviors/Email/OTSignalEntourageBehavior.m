//
//  OTSignalEntourageBehavior.m
//  entourage
//
//  Created by sergiu buceac on 11/22/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSignalEntourageBehavior.h"
#import <MessageUI/MessageUI.h>
#import "OTConsts.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface OTSignalEntourageBehavior () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) MFMailComposeViewController *mailController;

@end

@implementation OTSignalEntourageBehavior

- (void)sendMailFor:(OTEntourage *)entourage {
    NSString *subject = [NSString stringWithFormat:[OTAppAppearance reportActionSubject],
                         entourage.title,
                         entourage.author.displayName];
    [self sendMailWithSubject:subject body:nil];
}

- (void)sendPromoteEventMailFor:(OTEntourage *)entourage {
    NSString *subject = [OTAppAppearance promoteEventActionSubject:entourage.title];
    NSString *body = [OTAppAppearance promoteEventActionEmailBody:entourage.title];
    [self sendMailWithSubject:subject body:body];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.mailController dismissViewControllerAnimated:YES completion:^() {
        [self.owner dismissViewControllerAnimated:YES completion:^() {
            if(result == MFMailComposeResultSent)
                [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"mail_sent")];
            else if(result != MFMailComposeResultCancelled)
                [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"mail_send_failure")];
        }];
    }];
}

#pragma mark - private methods

- (void)sendMailWithSubject:(NSString *)subject body:(NSString*)body {
    if ([MFMailComposeViewController canSendMail]) {
        self.mailController = [MFMailComposeViewController new];
        [self.mailController setToRecipients:@[[OTAppAppearance reportActionToRecepient]]];
        [self.mailController setSubject:subject];
        if (body) {
            [self.mailController setMessageBody:body isHTML:NO];
        }
        self.mailController.mailComposeDelegate = self;
        [self.owner showViewController:self.mailController sender:self];
    }
    else {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"mail_not_configured")];
    }
}

@end
