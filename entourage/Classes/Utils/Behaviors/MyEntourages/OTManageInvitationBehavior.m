//
//  OTManageInvitationBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTManageInvitationBehavior.h"
#import "OTFeedItem.h"
#import "OTFeedItemFactory.h"
#import "SVProgressHUD.h"
#import "OTManageInvitationViewController.h"
#import "OTInvitationsCollectionSource.h"
#import "OTPendingInvitationsChangedDelegate.h"
#import "OTMyEntouragesDataSource.h"
#import "OTCollectionSourceBehavior.h"

@interface OTManageInvitationBehavior () <OTPendingInvitationsChangedDelegate>

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, strong) OTEntourageInvitation *invitation;

@end

@implementation OTManageInvitationBehavior

- (void)showFor:(OTEntourageInvitation *)invitation {
    self.invitation = invitation;
    [SVProgressHUD show];
    [[[OTFeedItemFactory createForType:nil andId:invitation.entourageId] getStateInfo] loadWithSuccess:^(OTFeedItem *feedItem) {
        self.feedItem = feedItem;
        [SVProgressHUD dismiss];
        [self.owner performSegueWithIdentifier:@"ManageInvitationSegue" sender:self];
    } error:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (BOOL)prepareSegueForManage:(UIStoryboardSegue *)segue {
    if([segue.identifier isEqualToString:@"ManageInvitationSegue"]) {
        OTManageInvitationViewController *controller = (OTManageInvitationViewController *)segue.destinationViewController;
        controller.feedItem = self.feedItem;
        controller.invitation = self.invitation;
        controller.pendingInvitationsChangedDelegate = self;
    }
    else
        return NO;
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
