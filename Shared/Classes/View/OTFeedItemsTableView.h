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

@class OTFeedItem;

@protocol OTFeedItemsTableViewDelegate <NSObject>

- (void)showFeedInfo:(OTFeedItem*)feedItem;
- (void)showPoiDetails:(OTPoi*)poi;
- (void)showUserProfile:(NSNumber*)userId;
- (void)doJoinRequest:(OTFeedItem*)feedItem;
- (void)showAnnouncementDetails:(OTAnnouncement *)feedItem;
@optional
- (void)loadMoreData;

@end

@interface OTFeedItemsTableView : UITableView <OTNewsFeedTableDelegate>

@property (nonatomic, weak) id<OTFeedItemsTableViewDelegate> feedItemsDelegate;

@property (nonatomic, strong) IBOutlet UIView *loadingView;

- (void)configureWithMapView:(MKMapView *)mapView;
- (void)updateItems:(NSArray *)items;
- (void)loadBegun;
- (void)setNoConnection;
- (void)setNoFeeds;
- (void)switchToGuide;
- (void)switchToFeeds;

@end
