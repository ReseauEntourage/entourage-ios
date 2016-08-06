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

@interface OTStatusChangedBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTStatusChangedBehavior

- (void)configureWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
}

- (void)startChangeStatus {
    [self.owner performSegueWithIdentifier:@"SegueChangeState" sender:self];
}

- (BOOL)prepareSegueForNextStatus:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"SegueChangeState"]) {
        OTChangeStateViewController *controller = (OTChangeStateViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
        controller.delegate = self;
    } else
        return NO;
    return YES;
}

#pragma mark - OTNextStatusProtocol


- (void)stoppedFeedItem {
    [self.owner.navigationController popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"stoppedItem")];
    });
}

- (void)closedFeedItem {
    [self.owner.navigationController popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"closedItem")];
    });
}

@end
