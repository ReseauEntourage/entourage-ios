//
//  OTMembersTableDataSource.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTableDataSourceBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTInviteBehavior.h"

@interface OTMembersTableDataSource : OTTableDataSourceBehavior

@property (nonatomic, weak) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (nonatomic, weak) IBOutlet OTInviteBehavior *inviteBehavior;

@end
