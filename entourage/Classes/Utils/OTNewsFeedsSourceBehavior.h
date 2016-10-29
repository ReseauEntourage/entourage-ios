//
//  OTNewsFeedsSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 10/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTNewsFeedsSourceDelegate.h"
#import "OTNewsFeedsFilter.h"
#import <MapKit/MapKit.h>

@interface OTNewsFeedsSourceBehavior : OTBehavior

@property (nonatomic, weak) id<OTNewsFeedsSourceDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *feedItems;

- (void)reloadItemsAt:(CLLocationCoordinate2D)coordinate withFilters:(OTNewsFeedsFilter *)filter;
- (void)loadMoreItems;
- (void)pause;
- (void)resume;

@end
