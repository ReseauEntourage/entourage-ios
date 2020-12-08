//
//  OTMailSenderBehavior.m
//  entourage
//
//  Created by veronica.gliga on 27/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTSignalEntourageBehavior.h"
#import "OTMailSenderBehavior.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTConsts.h"
#import <MessageUI/MessageUI.h>
#import "OTMainViewController.h"

@interface OTMailSenderBehavior () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) MFMailComposeViewController *mailController;

@end

@implementation OTMailSenderBehavior

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    if(!self.successMessage) {
        self.successMessage = OTLocalizedString(@"mail_sent");
    }
}

- (BOOL)sendMailWithSubject:(NSString *)subject andRecipient:(NSString *)recipient {
    return [self sendMailWithSubject:subject andRecipient:recipient body:nil];
}

- (BOOL)sendMailWithSubject:(NSString *)subject andRecipient:(NSString *)recipient body:(NSString*)body { 
    if ([self checkCanSend]) {
        [OTAppConfiguration configureNavigationControllerAppearance:self.owner.navigationController];
        self.mailController = [MFMailComposeViewController new];
        [self.mailController setToRecipients:@[recipient]];
        [self.mailController setSubject:subject];
        self.mailController.mailComposeDelegate = self;
        
        if (body) {
            [self.mailController setMessageBody:body isHTML:NO];
        }
        
        [OTAppConfiguration configureMailControllerAppearance:self.mailController];
        if ([self.owner isKindOfClass:[OTMainViewController class]]) {
            [self.owner.tabBarController showViewController:self.mailController sender:self];
        }
        else {
            [self.owner showViewController:self.mailController sender:self];
        }
        
        return YES;
    }
    return NO;
}

- (BOOL)sendCloseMail:(OTCloseReason)reason forItem:(OTEntourage *)feedItem{
    if([self checkCanSend]) {
        NSString *subject;
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
        [self sendMailWithSubject:subject andRecipient:[OTAppAppearance reportActionToRecepient]];
    }
    return NO;
}

- (BOOL)sendStructureMail:(NSString *)subject {
    if([self checkCanSend]) {
        [self sendMailWithSubject:subject andRecipient:[OTAppAppearance reportActionToRecepient]];
    }
    return NO;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.mailController dismissViewControllerAnimated:YES completion:^() {
        if(result == MFMailComposeResultSent)
            [SVProgressHUD showSuccessWithStatus:self.successMessage];
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
