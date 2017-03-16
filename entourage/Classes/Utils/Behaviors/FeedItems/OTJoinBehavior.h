//
//  OTJoinBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/5/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTFeedItem.h"
#import "OTJoinDelegate.h"

@interface OTJoinBehavior : OTBehavior<OTJoinDelegate>

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (BOOL)join:(OTFeedItem *)item;
- (BOOL)prepareSegueForMessage:(UIStoryboardSegue *)segue;

@end
