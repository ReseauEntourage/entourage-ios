//
//  OTPendingInvitationsChangedDelegate.h
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTEntourageInvitation.h"

@protocol OTPendingInvitationsChangedDelegate <NSObject>

- (void)noLongerPending:(OTEntourageInvitation *)invitation;

@end
