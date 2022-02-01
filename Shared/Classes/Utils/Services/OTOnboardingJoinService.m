//
//  OTOnboardingJoinService.m
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTOnboardingJoinService.h"
#import "OTConsts.h"
#import "OTInvitationsService.h"

@implementation OTOnboardingJoinService

- (void)checkForJoins:(void (^)(OTEntourageInvitation *))success withError:(void (^)(NSError *))failure {
    [[OTInvitationsService new] getInvitationsWithStatus:INVITATION_PENDING success:^(NSArray *invitations) {
        if(invitations.count == 0) {
            if(success)
                success(nil);
        }
        else
            [self doJoin:invitations withSuccess:success andError:failure];
    } failure:^(NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)doJoin:(NSArray *)invitations withSuccess:(void (^)(OTEntourageInvitation *))success andError:(void (^)(NSError *))failure {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^() {
        NSMutableArray *successfulInvitations = [NSMutableArray new];
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if(successfulInvitations.count > 0) {
                if(success)
                    success(successfulInvitations.firstObject);
            }
            else {
                if(failure)
                    failure(nil);
            }
        });

        OTInvitationsService *service = [OTInvitationsService new];
        for (OTEntourageInvitation *invitation in invitations) {
            dispatch_group_enter(group);
            [service acceptInvitation:invitation withSuccess:^() {
                @synchronized (successfulInvitations) {
                    [successfulInvitations addObject:invitation];
                }
                dispatch_group_leave(group);
            } failure:^(NSError *error) {
                dispatch_group_leave(group);
            }];
        }
    });
}

@end
