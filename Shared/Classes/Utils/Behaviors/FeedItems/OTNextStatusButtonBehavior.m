//
//  OTNextStatusButtonBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTNextStatusButtonBehavior.h"
#import "OTFeedItemFactory.h"
#import "OTConsts.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTTour.h"
#import "OTConfirmCloseViewController.h"
#import "OTCloseReason.h"
#import "OTTourStateTransition.h"
#import "NSUserDefaults+OT.h"

@interface OTNextStatusButtonBehavior () <OTConfirmCloseProtocol>

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<OTStatusChangedProtocol> delegate;

@end

@implementation OTNextStatusButtonBehavior

- (void)configureWith:(OTFeedItem *)feedItem
          andProtocol:(id<OTStatusChangedProtocol>)protocol
{
    self.feedItem = feedItem;
    self.delegate = protocol;
    [self updateButton];
}

#pragma mark - private methods

- (void)updateButton {
    FeedItemState currentState = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] getState];
    NSString *title = nil;
    SEL selector = nil;
    self.btnNextState.hidden = YES;
    Boolean isClosed = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] isClosed];
    
    if ([OTAppConfiguration supportsClosingFeedAction:self.feedItem]) {
        switch (currentState) {
            case FeedItemStateOngoing:
                title = OTLocalizedString(@"item_option_close");
                selector = @selector(doStopFeedItem);
                self.btnNextState.hidden = NO;
                break;
            case FeedItemStateOpen:
                title = OTLocalizedString(@"item_option_freeze");
                selector = @selector(doCloseFeedItemWithReason:);
                self.btnNextState.hidden = NO;
                break;
            case FeedItemStateClosed:
                if ([self.feedItem isKindOfClass:[OTTour class]]) {
                    title = OTLocalizedString(@"item_option_freeze");
                    selector = @selector(doCloseFeedItemWithReason:);
                    self.btnNextState.hidden = NO;
                }
                else {
                    title = OTLocalizedString(@"item_option_reopen");
                    selector = @selector(doReopenFeedItem);
                    self.btnNextState.hidden = NO;
                }
                break;
            case FeedItemStateJoinAccepted:
                title = OTLocalizedString(@"item_option_quit");
                selector = @selector(doQuitFeedItem);
                self.btnNextState.hidden = NO;
                break;
            case FeedItemStateJoinNotRequested:
                title = OTLocalizedString(@"join");
                selector = @selector(doJoinFeedItem);
                self.btnNextState.hidden = NO;
                break;
            case FeedItemStateJoinPending:
                title = OTLocalizedString(@"item_cancel_join");
                selector = @selector(doCancelJoinRequest);
                self.btnNextState.hidden = NO;
                break;
            default:
                break;
        }
    } else {
        switch (currentState) {
            case FeedItemStateJoinAccepted:
                title = OTLocalizedString(@"item_option_quit");
                selector = @selector(doQuitFeedItem);
                self.btnNextState.hidden = NO;
                break;
            case FeedItemStateJoinNotRequested:
                title = OTLocalizedString(@"join");
                selector = @selector(doJoinFeedItem);
                self.btnNextState.hidden = NO;
                break;
            case FeedItemStateJoinPending:
                title = OTLocalizedString(@"item_cancel_join");
                selector = @selector(doCancelJoinRequest);
                self.btnNextState.hidden = NO;
                break;
            default:
                break;
        }
    }
    
    [self.btnNextState addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.btnNextState setTitle:title forState:UIControlStateNormal];
}

- (BOOL)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ConfirmCloseSegue"]) {
        OTConfirmCloseViewController *confirmCloseVC = segue.destinationViewController;
        confirmCloseVC.feedItem = self.feedItem;
        confirmCloseVC.closeDelegate = self;
    }
    else
        return NO;
    return YES;
}

#pragma mark - state transitions

- (void)doStopFeedItem {
    [OTLogger logEvent:@"StopEntourageConfirm"];
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] stopWithSuccess:^() {
        [SVProgressHUD dismiss];
        [self.owner dismissViewControllerAnimated:NO completion:^{
            if(self.delegate)
                [self.delegate stoppedFeedItem];
        }];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (void)doCloseFeedItemWithReason: (OTCloseReason)reason {
    if ([self.feedItem isKindOfClass:[OTTour class]]) {
        [self feedItemClosedWithReason:reason];
    }
    else {
        [OTAppState showClosingConfirmationForFeedItem:self.feedItem
                                        fromController:self.owner
                                                sender:self];
    }
}

- (void)doQuitFeedItem {
    [OTLogger logEvent:@"QuitFromFeed"];
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] quitWithSuccess:^() {
        [SVProgressHUD dismiss];
        [self.owner dismissViewControllerAnimated:NO completion:^{
            if (self.delegate) {
                [self.delegate quitedFeedItem];
            }
        }];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (void)doCancelJoinRequest {
    [OTLogger logEvent:@"ExitEntourageConfirm"];
    [SVProgressHUD show];
    [OTAppState hideTabBar:NO];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] quitWithSuccess:^() {
        [SVProgressHUD dismiss];
        [OTLogger logEvent:@"CancelJoinRequest"];
        [self.owner dismissViewControllerAnimated:NO completion:^{
            if(self.delegate)
                [self.delegate cancelledJoinRequest];
        }];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (void)doJoinFeedItem {
    if ([NSUserDefaults standardUserDefaults].currentUser.isAnonymous) {
        [OTAppState presentAuthenticationOverlay:self.owner];
        return;
    }

    if(self.delegate)
        [self.delegate joinFeedItem];
}

- (void)doReopenFeedItem {
    
    [SVProgressHUD show];

    id stateTransition = [[OTFeedItemFactory createFor:self.feedItem] getStateTransition];
    [stateTransition reopenEntourageWithSuccess:^(BOOL isOk) {
        [SVProgressHUD dismiss];
        [self dismissOnClose:OTCloseReasonSuccesClose];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}



#pragma mark - OTConfirmCloseProtocol

- (void)feedItemClosedWithReason:(OTCloseReason)reason {
    [OTLogger logEvent:@"CloseEntourageConfirm"];
    
    if (reason == OTCloseReasonHelpClose) {
        [self dismissOnClose:reason];
        return;
    }
    
    BOOL outcome = (reason == OTCloseReasonSuccesClose) ? YES : NO;
    
    [SVProgressHUD show];

    id stateTransition = [[OTFeedItemFactory createFor:self.feedItem] getStateTransition];
    [stateTransition closeWithOutcome:outcome
        success:^(BOOL isTour) {
            [SVProgressHUD dismiss];
            [self dismissOnClose:reason];
        
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (void)dismissOnClose:(OTCloseReason) reason {
    [self.owner dismissViewControllerAnimated:NO completion:^{
        if (self.delegate) {
            [self.delegate closedFeedItemWithReason: reason];
        }
    }];
}

@end
