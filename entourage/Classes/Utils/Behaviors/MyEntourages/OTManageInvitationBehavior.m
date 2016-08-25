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

@interface OTManageInvitationBehavior ()

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
    }
    else
        return NO;
    return YES;
}

@end
