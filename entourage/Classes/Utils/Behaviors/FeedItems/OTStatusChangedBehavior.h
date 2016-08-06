//
//  OTStatusChangedBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTNextStatusButtonBehavior.h"

@interface OTStatusChangedBehavior : OTBehavior <OTStatusChangedProtocol>

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)configureWith:(OTFeedItem *)feedItem;
- (void)startChangeStatus;
- (BOOL)prepareSegueForNextStatus:(UIStoryboardSegue *)segue;

@end
