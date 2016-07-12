//
//  OTTourDetailsOptionsViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 08/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTTour.h"

@protocol OTFeedItemDetailsOptionsDelegate <NSObject>

@required
- (void)promptToCloseFeedItem;
- (void)feedItemFrozen:(OTFeedItem *)item;

@end

@interface OTFeedItemDetailsOptionsViewController : UIViewController

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<OTFeedItemDetailsOptionsDelegate> delegate;

@end
