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


@interface OTMailSenderBehavior () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) MFMailComposeViewController *mailController;

@end

@implementation OTMailSenderBehavior

- (void)sendMailWithSubject:(NSString *)subject andRecipient:(NSString *)recipient {
    if([MFMailComposeViewController canSendMail]) {
        self.mailController = [MFMailComposeViewController new];
        [self.mailController setToRecipients:@[recipient]];
        [self.mailController setSubject:subject];
        self.mailController.mailComposeDelegate = self;
        [self.owner showViewController:self.mailController sender:self];
    }
    else
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"mail_not_configured")];
}

- (void)sendCloseMail:(OTCloseReason)reason forItem:(OTEntourage *)feedItem{
    NSString *subject = [NSString new];
    switch (reason) {
    case SuccesClose:
            subject =[NSString stringWithFormat:OTLocalizedString(@"successful_close_mail"), feedItem.title];
        break;
    case BlockedClose:
            subject =[NSString stringWithFormat:OTLocalizedString(@"blocked_close_mail"), feedItem.title];
        break;
    case HelpClose:
            subject =[NSString stringWithFormat:OTLocalizedString(@"help_close_mail"), feedItem.title];
        break;
    default:
        break;
    }
    [self sendMailWithSubject:subject andRecipient:CLOSE_EMAIL_RECIPIENT];
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

@end
