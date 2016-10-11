//
//  OTInviteBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTInviteSourceViewController.h"
#import "OTFeedItem.h"

@interface OTInviteBehavior : OTBehavior <InviteSourceDelegate, InviteSuccessDelegate>

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)configureWith:(OTFeedItem *)feedItem;
- (void)startInvite;
- (BOOL)prepareSegueForInvite:(UIStoryboardSegue *)segue;

@end
