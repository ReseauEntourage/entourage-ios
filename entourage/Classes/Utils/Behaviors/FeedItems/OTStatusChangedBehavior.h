//
//  OTStatusChangedBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTNextStatusButtonBehavior.h"
#import "OTEditEntourageBehavior.h"
#import "OTJoinBehavior.h"

@interface OTStatusChangedBehavior : OTBehavior <OTStatusChangedProtocol>

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet OTEditEntourageBehavior *editEntourageBehavior;
@property (nonatomic, weak) IBOutlet OTJoinBehavior *joinBehavior;

- (void)configureWith:(OTFeedItem *)feedItem;
- (IBAction)startChangeStatus;
- (BOOL)prepareSegueForNextStatus:(UIStoryboardSegue *)segue;

@end
