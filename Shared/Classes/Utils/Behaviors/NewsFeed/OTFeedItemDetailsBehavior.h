//
//  OTFeedItemDetailsBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTFeedItem.h"

@interface OTFeedItemDetailsBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)showDetails:(OTFeedItem *)feedItem;
- (BOOL)prepareSegueForDetails:(UIStoryboardSegue *)segue;

@end
