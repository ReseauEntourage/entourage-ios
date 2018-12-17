//
//  OTNewsFeedsSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 10/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTNewsFeedsSourceDelegate.h"
#import "OTNewsFeedTableDelegate.h"
#import "OTNewsFeedsFilter.h"
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface OTNewsFeedsSourceBehavior : OTBehavior


@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, weak) id<OTNewsFeedsSourceDelegate> delegate;
@property (nonatomic, weak) id<OTNewsFeedTableDelegate> tableDelegate;

@property (nonatomic, strong, readonly) NSArray *feedItems;
@property (nonatomic, assign) CLLocationCoordinate2D lastOkCoordinate;
@property (nonatomic, strong) OTNewsFeedsFilter *currentFilter;
@property (nonatomic) BOOL showEventsOnly;
@property (nonatomic, assign, readonly) int radius;
@property (nonatomic, strong) NSString *lastEventGuid;

- (void)reloadItemsAt:(CLLocationCoordinate2D)coordinate
          withFilters:(OTNewsFeedsFilter *)filter
          forceReload:(BOOL)forceReload;
- (void)loadEventsAt:(CLLocationCoordinate2D)coordinate;
- (void)loadMoreItems;
- (void)getNewItems;
- (void)pause;
- (void)resume;

- (void)addFeedItemToFront:(id)feedItem;
- (void)removeAllFeedItems;

@end
