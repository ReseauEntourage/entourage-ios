//
//  OTManageInvitationBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEntourageInvitation.h"
#import "OTInvitationsCollectionSource.h"
#import "OTMyEntouragesViewController.h"

@interface OTManageInvitationBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet OTMyEntouragesViewController *owner;

- (void)configureWith:(OTInvitationsCollectionSource *)collectionDataSource;
- (BOOL)prepareSegueForManage:(UIStoryboardSegue *)segue;
- (void)showFor:(OTEntourageInvitation *)invitation;

@end
