//
//  OTShareFeedItemBehavior.h
//  entourage
//
//  Created by sergiu.buceac on 06/04/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTBehavior.h"
#import "OTFeedItem.h"

@interface OTShareFeedItemBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

-(void) configureWith:(OTFeedItem *)feedItem;

- (IBAction)sharePublic:(id)sender;
- (IBAction)shareMember:(id)sender;

@end
