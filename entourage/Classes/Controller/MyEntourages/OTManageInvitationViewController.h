//
//  OTManageInvitationViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTEntourageInvitation.h"
#import "OTPendingInvitationsChangedDelegate.h"

@interface OTManageInvitationViewController : UIViewController

@property (nonatomic, weak) id<OTPendingInvitationsChangedDelegate> pendingInvitationsChangedDelegate;

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, strong) OTEntourageInvitation *invitation;

@end
