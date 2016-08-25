//
//  OTInvitationChangedBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEntourageInvitation.h"
#import "OTPendingInvitationsChangedDelegate.h"

@interface OTInvitationChangedBehavior : OTBehavior

@property (nonatomic, weak) id<OTPendingInvitationsChangedDelegate> pendingInvitationChangedDelegate;

- (void)accept:(OTEntourageInvitation *)invitation;
- (void)ignore:(OTEntourageInvitation *)invitation;

@end
