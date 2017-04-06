//
//  OTStatusChangedBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTStatusChangedBehavior.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "OTChangeStateViewController.h"
#import "OTMainViewController.h"
#import "OTCloseReason.h"

@interface OTStatusChangedBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTStatusChangedBehavior

- (void)configureWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
}

- (IBAction)startChangeStatus {
    [OTLogger logEvent:@"OpenEntourageOptionsOverlay"];
    [self.owner performSegueWithIdentifier:@"SegueChangeState" sender:self];
}

- (BOOL)prepareSegueForNextStatus:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"SegueChangeState"]) {
        OTChangeStateViewController *controller = (OTChangeStateViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
        controller.delegate = self;
        controller.editEntourageBehavior = self.editEntourageBehavior;
    } else
        return NO;
    return YES;
}

#pragma mark - OTNextStatusProtocol

- (void)stoppedFeedItem {
    [self popToMainController];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"stopped_item")];
    });
}

- (void)closedFeedItemWithReason: (OTCloseReason) reason {
    [self popToMainController];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSDictionary *userInfo =  @{ @kNotificationSendReasonKey: @(reason), @kNotificationFeedItemKey: self.feedItem};
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationSendCloseMail object:nil userInfo:userInfo];
        if(reason == OTCloseReasonHelpClose)
            return;
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"closed_item")];
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
    });
}

- (void)quitedFeedItem {
    [self popToMainController];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"quitted_item")];
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
    });
}

- (void)cancelledJoinRequest {
    [self popToMainController];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"cancelled_join_request")];
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
    });
}

- (void)joinFeedItem {
    [self.owner dismissViewControllerAnimated:YES completion:^{
        [self.joinBehavior join:self.feedItem];
    }];
}

- (void)popToMainController {
    for (UIViewController* viewController in self.owner.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[OTMainViewController class]]) {
            [self.owner.navigationController popToViewController:viewController animated:YES];
            break;
        }
    }
}

@end
