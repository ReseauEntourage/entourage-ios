//
//  OTFeedItemSummaryView.h
//  entourage
//
//  Created by Ciprian Habuc on 20/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"

@protocol OTFeedItemSummaryDelegate <NSObject>

- (void)doShowProfile;

@end

@interface OTFeedItemSummaryView : UIView

@property (nonatomic, weak) id<OTFeedItemSummaryDelegate> delegate;

- (void)setupWithFeedItem:(OTFeedItem *)feedItem;

@end
