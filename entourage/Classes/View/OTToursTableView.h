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

@protocol OTToursTableViewDelegate <NSObject>

- (void)showFeedInfo:(OTFeedItem*)feedItem;
- (void)showUserProfile:(NSNumber*)userId;
- (void)doJoinRequest:(OTFeedItem*)feedItem;
@optional
- (void)loadMoreTours;

@end

@interface OTToursTableView : UITableView

@property (nonatomic, weak) id<OTToursTableViewDelegate> toursDelegate;

- (void)configureWithMapView:(MKMapView *)mapView;

- (void)addFeedItems:(NSArray*)feedItems;
- (void)addFeedItem:(OTFeedItem*)feedItem;
- (void)removeFeedItem:(OTFeedItem*)feedItem;
- (void)removeAll;

- (void)addEntourages:(NSArray*)entourages;

@end
