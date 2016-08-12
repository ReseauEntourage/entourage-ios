//
//  OTJoinBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/5/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTFeedItem.h"
#import "OTFeedItemJoinRequestViewController.h"

@interface OTJoinBehavior : OTBehavior<OTFeedItemJoinRequestDelegate>

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)configureWith:(OTFeedItem *)feedItem;
- (BOOL)prepareSegueForMessage:(UIStoryboardSegue *)segue;
- (void)joinFeedItem;

@end
