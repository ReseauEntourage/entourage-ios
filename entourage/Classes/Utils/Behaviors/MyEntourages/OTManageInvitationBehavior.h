//
//  OTManageInvitationBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTEntourageInvitation.h"

@interface OTManageInvitationBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (BOOL)prepareSegueForManage:(UIStoryboardSegue *)segue;
- (void)showFor:(OTEntourageInvitation *)invitation;

@end
