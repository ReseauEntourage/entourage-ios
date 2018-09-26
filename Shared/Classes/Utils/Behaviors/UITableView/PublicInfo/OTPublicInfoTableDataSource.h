//
//  OTPublicInfoTableDataSource.h
//  entourage
//
//  Created by sergiu buceac on 10/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTableDataSourceBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTInviteBehavior.h"
#import "OTStatusChangedBehavior.h"

@interface OTPublicInfoTableDataSource : OTTableDataSourceBehavior
@property (nonatomic, weak) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (nonatomic, weak) IBOutlet OTInviteBehavior *inviteBehavior;
@property (nonatomic, weak) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;
@end
