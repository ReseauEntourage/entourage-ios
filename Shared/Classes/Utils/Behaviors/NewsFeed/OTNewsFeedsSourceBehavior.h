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

@property (nonatomic, strong) NSMutableArray *feedItems;
@property (nonatomic, assign) CLLocationCoordinate2D lastOkCoordinate;
@property (nonatomic, strong) OTNewsFeedsFilter *currentFilter;
@property (nonatomic) BOOL showEventsOnly;
@property (nonatomic, assign, readonly) int radius;

- (void)reloadItemsAt:(CLLocationCoordinate2D)coordinate withFilters:(OTNewsFeedsFilter *)filter;
- (void)loadEventsAt:(CLLocationCoordinate2D)coordinate startingAfter:(NSString *)eventUuid;
- (void)loadMoreItems;
- (void)getNewItems;
- (void)pause;
- (void)resume;

@end
