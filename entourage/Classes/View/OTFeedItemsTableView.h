//
//  OTToursTableView.h
//  entourage
//
//  Created by Mihai Ionescu on 06/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class OTFeedItem;

@protocol OTFeedItemsTableViewDelegate <NSObject>

- (void)showFeedInfo:(OTFeedItem*)feedItem;
- (void)showUserProfile:(NSNumber*)userId;
- (void)doJoinRequest:(OTFeedItem*)feedItem;
@optional
- (void)loadMoreData;

@end

@interface OTFeedItemsTableView : UITableView

@property (nonatomic, weak) id<OTFeedItemsTableViewDelegate> feedItemsDelegate;

- (void)configureWithMapView:(MKMapView *)mapView;

- (void)addFeedItems:(NSArray*)feedItems;
- (void)addFeedItem:(OTFeedItem*)feedItem;
- (void)removeFeedItem:(OTFeedItem*)feedItem;
- (void)removeAll;
- (void)loadBegun;
- (void)setNoConnection;
- (void)setNoFeeds;

- (NSArray *)items;
- (NSUInteger)itemsCount;

@end
