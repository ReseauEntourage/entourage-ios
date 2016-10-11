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
#import "SVProgressHUD.h"

@interface OTNextStatusButtonBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<OTStatusChangedProtocol> delegate;

@end

@implementation OTNextStatusButtonBehavior

- (void)configureWith:(OTFeedItem *)feedItem andProtocol:(id<OTStatusChangedProtocol>)protocol {
    self.feedItem = feedItem;
    self.delegate = protocol;
    [self updateButton];
}

#pragma mark - private methods

- (void)updateButton {
    FeedItemState currentState = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] getState];
    NSString *title = nil;
    SEL selector = nil;
    switch (currentState) {
        case FeedItemStateOngoing:
            title = OTLocalizedString(@"item_option_close");
            selector = @selector(doStopFeedItem);
            break;
        case FeedItemStateOpen:
        case FeedItemStateClosed:
            title = OTLocalizedString(@"item_option_freeze");
            selector = @selector(doCloseFeedItem);
            break;
        case FeedItemStateJoinAccepted:
            title = OTLocalizedString(@"item_option_quit");
            selector = @selector(doQuitFeedItem);
            break;
        default:
            self.btnNextState.hidden = YES;
            selector = @selector(doStopFeedItem);
            break;
    }
    [self.btnNextState addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.btnNextState setTitle:title forState:UIControlStateNormal];
}

#pragma mark - state transitions

- (void)doStopFeedItem {
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

- (void)doCloseFeedItem {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] closeWithSuccess:^(BOOL isTour) {
        [SVProgressHUD dismiss];
        [self.owner dismissViewControllerAnimated:NO completion:^{
            if(self.delegate)
                [self.delegate closedFeedItem];
        }];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (void)doQuitFeedItem {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] quitWithSuccess:^() {
        [SVProgressHUD dismiss];
        [self.owner dismissViewControllerAnimated:NO completion:^{
            if(self.delegate)
                [self.delegate closedFeedItem];
        }];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

@end
