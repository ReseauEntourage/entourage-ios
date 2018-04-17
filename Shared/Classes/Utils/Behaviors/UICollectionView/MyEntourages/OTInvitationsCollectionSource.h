//
//  OTInvitationsCollectionSource.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTCollectionViewDataSourceBehavior.h"
#import "OTEntourageInvitation.h"
@class OTManageInvitationBehavior;

@interface OTInvitationsCollectionSource : OTCollectionViewDataSourceBehavior

@property (nonatomic, weak) IBOutlet OTManageInvitationBehavior* manageInvitations;

- (void)removeInvitation:(OTEntourageInvitation *)invitation;

@end
