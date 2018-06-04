//
//  OTInvitationChangedBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTInvitationChangedBehavior.h"
#import "OTInvitationsService.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OTConsts.h"

@implementation OTInvitationChangedBehavior

- (void)accept:(OTEntourageInvitation *)invitation {
    [SVProgressHUD show];
    [[OTInvitationsService new] acceptInvitation:invitation withSuccess:^() {
        [SVProgressHUD dismiss];
        [self.pendingInvitationChangedDelegate noLongerPending:invitation];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"acceptJoinFailed")];
    }];
}

- (void)ignore:(OTEntourageInvitation *)invitation {
    [SVProgressHUD show];
    [[OTInvitationsService new] rejectInvitation:invitation withSuccess:^() {
        [SVProgressHUD dismiss];
        [self.pendingInvitationChangedDelegate noLongerPending:invitation];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"ignoreJoinFailed")];
    }];
}

@end
