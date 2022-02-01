//
//  OTJoinBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/5/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTJoinBehavior.h"
#import "OTFeedItemFactory.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTConsts.h"
#import "OTFeedItemJoinOptionsViewController.h"
#import "NSUserDefaults+OT.h"

@interface OTJoinBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTJoinBehavior

- (BOOL)join:(OTFeedItem *)item {
    self.feedItem = item;
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
    if ([NSUserDefaults standardUserDefaults].currentUser.isAnonymous) {
        [OTAppState presentAuthenticationOverlay:self.owner];
        return;
    }

    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] sendJoinRequest:^(OTFeedItemJoiner *joiner) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self sendJoinRequestCompleteNotification:joiner.status];
        [SVProgressHUD dismiss];
        if ([joiner.status isEqualToString:JOIN_PENDING]) {
            [self.owner performSegueWithIdentifier:@"JoinRequestSegue" sender:self];
        }
    } orFailure:^(NSError *error, BOOL isTour) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"error")];
    }];
}

- (void)sendJoinRequestCompleteNotification:(NSString*)status {
    NSDictionary *userInfo = @{kWSStatus:status};
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationJoinRequestSent object:nil userInfo:userInfo];
}

@end
