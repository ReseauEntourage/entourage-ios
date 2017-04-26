//
//  OTMailSenderBehavior.m
//  entourage
//
//  Created by veronica.gliga on 27/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSignalEntourageBehavior.h"
#import "OTMailSenderBehavior.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import <MessageUI/MessageUI.h>
#import "OTMainViewController.h"

#define CLOSE_EMAIL_RECIPIENT @"contact@entourage.social"
#define STRUCTURE_EMAIL_RECIPIENT @"contact@entourage.social"

@interface OTMailSenderBehavior () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) MFMailComposeViewController *mailController;

@end

@implementation OTMailSenderBehavior

- (BOOL)sendMailWithSubject:(NSString *)subject andRecipient:(NSString *)recipient {
    if([self checkCanSend]) {
        self.mailController = [MFMailComposeViewController new];
        [self.mailController setToRecipients:@[recipient]];
        [self.mailController setSubject:subject];
        self.mailController.mailComposeDelegate = self;
        [self.owner showViewController:self.mailController sender:self];
        return YES;
    }
    return NO;
}

- (BOOL)sendCloseMail:(OTCloseReason)reason forItem:(OTEntourage *)feedItem{
    if([self checkCanSend]) {
        NSString *subject = [NSString new];
        switch (reason) {
            case OTCloseReasonSuccesClose:
                subject = [NSString stringWithFormat:OTLocalizedString(@"successful_close_mail"), feedItem.title];
                break;
            case OTCloseReasonBlockedClose:
                subject = [NSString stringWithFormat:OTLocalizedString(@"blocked_close_mail"), feedItem.title];
                break;
            case OTCloseReasonHelpClose:
                subject = [NSString stringWithFormat:OTLocalizedString(@"help_close_mail"), feedItem.title];
                break;
            default:
                break;
        }
        [self sendMailWithSubject:subject andRecipient:CLOSE_EMAIL_RECIPIENT];
    }
    return NO;
}

- (BOOL)sendStructureMail:(NSString *)subject {
    if([self checkCanSend]) {
        [self sendMailWithSubject:subject andRecipient:STRUCTURE_EMAIL_RECIPIENT];
    }
    return NO;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.mailController dismissViewControllerAnimated:YES completion:^() {
        if(result == MFMailComposeResultSent)
            [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"mail_sent")];
        else if(result != MFMailComposeResultCancelled)
            [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"mail_send_failure")];
    }];
}

#pragma mark - private members

- (BOOL)checkCanSend {
    if([MFMailComposeViewController canSendMail])
        return YES;
    [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"mail_not_configured")];
    return NO;
}

@end
