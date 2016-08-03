//
//  OTFeedItemJoinRequestViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 01/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"

@protocol OTFeedItemJoinRequestDelegate  <NSObject>

- (void)dismissFeedItemJoinRequestController;

@end

@interface OTFeedItemJoinRequestViewController : UIViewController

@property (nonatomic, weak) id<OTFeedItemJoinRequestDelegate> feedItemJoinRequestDelegate;
@property (nonatomic, strong) OTFeedItem *feedItem;

@end
