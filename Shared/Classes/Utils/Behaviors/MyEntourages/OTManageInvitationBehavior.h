//
//  OTManageInvitationBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEntourageInvitation.h"
#import "OTToggleVisibleBehavior.h"
@class OTInvitationsCollectionSource;
@class OTMyEntouragesDataSource;

@interface OTManageInvitationBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet OTInvitationsCollectionSource *invitationsCollectionSource;
@property (nonatomic, weak) IBOutlet OTMyEntouragesDataSource *entouragesDataSource;
@property (nonatomic, weak) IBOutlet OTToggleVisibleBehavior *toggleCollectionView;

- (BOOL)prepareSegueForManage:(UIStoryboardSegue *)segue;
- (void)showFor:(OTEntourageInvitation *)invitation;

@end
