//
//  OTJoinBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/5/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTJoinBehavior.h"
#import "OTFeedItemFactory.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTConsts.h"
#import "OTFeedItemJoinOptionsViewController.h"

@interface OTJoinBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTJoinBehavior

- (BOOL)join:(OTFeedItem *)item {
    self.feedItem = item;
    FeedItemState state = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] getState];
    
    // EMA-2389
    if ([item isNeighborhood] || [item isPrivateCircle]) {
        [self startJoin];
        return YES;
    }
    else if (state != FeedItemStateJoinNotRequested) {
        return NO;
    }
    
    [self startJoin];
    
    return YES;
}

- (BOOL)prepareSegueForMessage:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"JoinRequestSegue"]) {
        OTFeedItemJoinOptionsViewController *controller = (OTFeedItemJoinOptionsViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
    }
    else
        return NO;
    return YES;
}

#pragma mark - private methods

- (void)startJoin {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] sendJoinRequest:^(OTFeedItemJoiner *joiner) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self sendJoinRequestCompleteNotification:joiner.status];
        [SVProgressHUD dismiss];
        [self.owner performSegueWithIdentifier:@"JoinRequestSegue" sender:self];
    } orFailure:^(NSError *error, BOOL isTour) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"error")];
    }];
}

- (void)sendJoinRequestCompleteNotification:(NSString*)status {
    NSDictionary *userInfo = @{kWSStatus:status};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationJoinRequestSent object:nil userInfo:userInfo];
}

@end
