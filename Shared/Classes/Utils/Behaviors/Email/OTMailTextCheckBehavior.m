//
//  OTMailTextCheckBehavior.m
//  entourage
//
//  Created by sergiu buceac on 11/22/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTMailTextCheckBehavior.h"
#import <MessageUI/MessageUI.h>
#import "OTConsts.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface OTMailTextCheckBehavior () <UITextViewDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation OTMailTextCheckBehavior

- (void)initialize {
    self.txtWithEmailLinks.delegate = self;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    [self sendMail:textView range:characterRange];
    return NO;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.owner.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultSent) {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"mail_sent")];
    }
    else if (result != MFMailComposeResultCancelled) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"mail_send_failure")];
    }
}

#pragma mark - private methods

- (void)sendMail:(UITextView *)textView range:(NSRange)range {
    if ([MFMailComposeViewController canSendMail]) {
        
        [OTAppConfiguration configureNavigationControllerAppearance:self.owner.navigationController];
        MFMailComposeViewController *mailer = [MFMailComposeViewController new];
        NSString *to = [textView.text substringWithRange:range];
        [mailer setToRecipients:@[to]];
        mailer.mailComposeDelegate = self;
        
        [OTAppConfiguration configureMailControllerAppearance:mailer];
        
        [self.owner showViewController:mailer sender:self];
    }
    else {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"mail_not_configured")];
    }
}

@end
