//
//  OTManageInvitationBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTManageInvitationBehavior.h"
#import "OTFeedItem.h"
#import "OTFeedItemFactory.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTManageInvitationViewController.h"
#import "OTInvitationsCollectionSource.h"
#import "OTPendingInvitationsChangedDelegate.h"
#import "OTMyEntouragesDataSource.h"
#import "OTCollectionSourceBehavior.h"

@interface OTManageInvitationBehavior () <OTPendingInvitationsChangedDelegate>

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, strong) OTEntourageInvitation *invitation;
@property (nonatomic) BOOL isLoadingFeedItem;

@end

@implementation OTManageInvitationBehavior

- (void)showFor:(OTEntourageInvitation *)invitation {
    if (self.isLoadingFeedItem) return;
    self.isLoadingFeedItem = YES;
    self.invitation = invitation;
    [SVProgressHUD show];
    [[[OTFeedItemFactory createForType:nil andId:invitation.entourageId] getStateInfo] loadWithSuccess:^(OTFeedItem *feedItem) {
        self.feedItem = feedItem;
        [SVProgressHUD dismiss];
        if (self.owner != nil && self.owner.parentViewController != nil) {
            [self.owner performSegueWithIdentifier:@"ManageInvitationSegue" sender:self];
        }
        self.isLoadingFeedItem = NO;
    } error:^(NSError *error) {
        [SVProgressHUD dismiss];
        self.isLoadingFeedItem = NO;
    }];
}

- (BOOL)prepareSegueForManage:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"ManageInvitationSegue"]) {
        OTManageInvitationViewController *controller = (OTManageInvitationViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
        controller.invitation = self.invitation;
        controller.pendingInvitationsChangedDelegate = self;
        controller.hidesBottomBarWhenPushed = YES;
    }
    else {
        return NO;
    }
    
    return YES;
}

#pragma mark - OTPendingInvitationsChangedDelegate

- (void)noLongerPending:(OTEntourageInvitation *)invitation {
    [self.owner.navigationController popViewControllerAnimated:YES];
    [self.invitationsCollectionSource removeInvitation:invitation];
    [self.toggleCollectionView toggle:[self.invitationsCollectionSource.dataSource.items count] > 0 animated:YES];
    [self.entouragesDataSource loadData];
}

@end
