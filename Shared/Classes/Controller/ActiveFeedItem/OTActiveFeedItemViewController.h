//
//  OTActiveFeedItemViewController.h
//  entourage
//
//  Created by sergiu buceac on 8/4/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"

@interface OTActiveFeedItemViewController : UIViewController

@property (nonatomic, assign) BOOL inviteBehaviorTriggered;
@property (nonatomic, strong) OTFeedItem *feedItem;
- (void)reloadMessages;
@end
