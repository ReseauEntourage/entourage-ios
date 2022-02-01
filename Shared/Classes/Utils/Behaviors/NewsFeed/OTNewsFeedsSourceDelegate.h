//
//  OTNewsFeedsSourceDelegate.h
//  entourage
//
//  Created by sergiu buceac on 10/28/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OTNewsFeedsSourceDelegate <NSObject>

- (void)itemsRemoved;
- (void)itemsUpdated;
- (void)errorLoadingFeedItems:(NSError *)error;
- (void)errorLoadingNewFeedItems:(NSError *)error;

@end
