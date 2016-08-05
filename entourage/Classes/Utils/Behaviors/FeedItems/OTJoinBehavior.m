//
//  OTJoinBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/5/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJoinBehavior.h"
#import "OTFeedItemFactory.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"

@interface OTJoinBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTJoinBehavior

- (void)configureWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
}

- (void)prepareSegueForMessage:(UIStoryboardSegue *)segue {
    OTFeedItemJoinRequestViewController *controller = (OTFeedItemJoinRequestViewController *)segue.destinationViewController;
    controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    controller.feedItem = self.feedItem;
    controller.feedItemJoinRequestDelegate = self;
}

- (void)joinFeedItem {
    FeedItemState state = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] getState];
    if(state != FeedItemStateJoinNotRequested)
        return;
    [self startJoin];
}

#pragma mark - OTFeedItemJoinRequestDelegate

- (void)dismissFeedItemJoinRequestController {
    [self.owner dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private methods

- (void)startJoin {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] sendJoinRequest:^(OTTourJoiner *joiner) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [SVProgressHUD dismiss];
        [self.owner performSegueWithIdentifier:@"JoinRequestSegue" sender:self];
    } orFailure:^(NSError *error, BOOL isTour) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"error")];
    }];
}

@end
