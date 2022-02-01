//
//  OTStatusChangedBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTStatusChangedBehavior.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTConsts.h"
#import "OTChangeStateViewController.h"
#import "OTMainViewController.h"
#import "OTCloseReason.h"
#import "OTTour.h"
#import "Analytics_keys.h"

#define ACTION_DELAY 0.3f

@interface OTStatusChangedBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTStatusChangedBehavior

- (void)configureWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
}

- (IBAction)startChangeStatus {
    [OTLogger logEvent:Show_Menu_Options];
    [self.owner performSegueWithIdentifier:@"SegueChangeState" sender:self];
}

- (BOOL)prepareSegueForNextStatus:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"SegueChangeState"]) {
        OTChangeStateViewController *controller = (OTChangeStateViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
        controller.delegate = self;
        controller.shouldShowTabBarOnClose = self.shouldShowTabBarWhenFinished;
        controller.editEntourageBehavior = self.editEntourageBehavior;
    } else
        return NO;
    return YES;
}

#pragma mark - OTNextStatusProtocol

- (void)stoppedFeedItem {
    [self popToRootController];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, ACTION_DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"stopped_item")];
    });
}

- (void)closedFeedItemWithReason: (OTCloseReason) reason {
    [self popToRootController];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [OTAppState hideTabBar:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, ACTION_DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(![self.feedItem isKindOfClass:[OTTour class]]) {
            NSDictionary *userInfo =  @{ @kNotificationSendReasonKey: @(reason), @kNotificationFeedItemKey: self.feedItem};
            [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationSendCloseMail object:nil userInfo:userInfo];
        }
        if (reason == OTCloseReasonHelpClose) {
            return;
        }
        
        [SVProgressHUD showSuccessWithStatus:[OTAppAppearance closeFeedItemConformationTitle:self.feedItem]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
    });
}

- (void)quitedFeedItem {
    [self popToRootController];
    [OTAppState hideTabBar:NO];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, ACTION_DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:[OTAppAppearance quitFeedItemConformationTitle:self.feedItem]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
    });
}

- (void)cancelledJoinRequest {
    [self popToRootController];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, ACTION_DELAY * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"cancelled_join_request")];
        [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationReloadData object:nil];
    });
}

- (void)joinFeedItem {
    [self.owner dismissViewControllerAnimated:YES completion:^{
        [self.joinBehavior join:self.feedItem];
    }];
}

- (void)popToRootController {
    [OTAppState popToRootCurrentTab];
}

@end
