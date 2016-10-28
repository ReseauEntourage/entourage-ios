//
//  OTNewsFeedsSourceDelegate.h
//  entourage
//
//  Created by sergiu buceac on 10/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OTNewsFeedsSourceDelegate <NSObject>

- (void)clearData;
- (void)feedItemsLoaded:(NSArray *)feedItems;
- (void)newFeedItemsReceived:(NSArray *)newFeedItems;

@optional

- (void)errorLoadingFeedItems;
- (void)errorGettingNewFeedItems;

@end
