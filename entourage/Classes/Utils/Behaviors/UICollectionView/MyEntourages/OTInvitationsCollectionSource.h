//
//  OTInvitationsCollectionSource.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTCollectionViewDataSourceBehavior.h"
#import "OTManageInvitationBehavior.h"

@interface OTInvitationsCollectionSource : OTCollectionViewDataSourceBehavior

@property (nonatomic, weak) IBOutlet OTManageInvitationBehavior* manageInvitations;

@end
