//
//  OTToursTableView.h
//  entourage
//
//  Created by Mihai Ionescu on 06/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OTPoi.h"
#import "OTNewsFeedTableDelegate.h"
#import "OTAnnouncement.h"

#define MAPVIEW_HEIGHT 224.f

@class OTFeedItem;

@protocol OTFeedItemsTableViewDelegate <NSObject>

- (void)showFeedInfo:(OTFeedItem*)feedItem;
- (void)showPoiDetails:(OTPoi*)poi;
- (void)showUserProfile:(NSNumber*)userId;
- (void)doJoinRequest:(OTFeedItem*)feedItem;
- (void)showAnnouncementDetails:(OTAnnouncement *)feedItem;
- (void)mapDidBecomeVisible:(BOOL)visible;

// Filtering
- (void)showEventsOnly;
- (void)showAllFeedItems;

@optional
- (void)loadMoreData;
- (void)didPanHeaderDown;

@end

@interface OTFeedItemsTableView : UITableView <OTNewsFeedTableDelegate>

@property (nonatomic, weak) id<OTFeedItemsTableViewDelegate> feedItemsDelegate;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic) BOOL showEventsOnly;
@property (nonatomic) BOOL showSolidarityGuidePOIs;

- (void)configureWithMapView:(MKMapView *)mapView;

- (void)updateWithMapView:(MKMapView*)mapView
                mapHeight:(CGFloat)mapHeight
               showFilter:(BOOL)showFilter;

- (void)updateItems:(NSArray *)items;
- (void)loadBegun;
- (void)setNoConnection;
- (void)setNoFeeds;
- (void)switchToGuide;
- (void)switchToFeeds;

- (CGFloat)feedsFilterHeaderHeight;
- (UIView*)headerViewWithMap:(MKMapView*)mapView
                   mapHeight:(CGFloat)mapHeight
                  showFilter:(BOOL)showFilter;

@end
