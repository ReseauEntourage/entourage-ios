//
//  OTFeedItemInfoView.h
//  entourage
//
//  Created by Ciprian Habuc on 21/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"

@protocol OTFeedItemInfoDelegate <NSObject>

- (void)doJoinTour;

@end

@interface OTFeedItemInfoView : UIView

@property (nonatomic, weak) id<OTFeedItemInfoDelegate> delegate;

- (void)setupWithFeedItem:(OTFeedItem *)feedItem;

@end
