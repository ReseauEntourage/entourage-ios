//
//  OTToursTableView.h
//  entourage
//
//  Created by Mihai Ionescu on 06/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class OTTour;

@protocol OTToursTableViewDelegate <NSObject>

- (void)showTourInfo:(OTTour*)tour;
- (void)showUserProfile:(NSNumber*)userId;
- (void)doJoinRequest:(OTTour*)tour;
@optional
- (void)loadMoreTours;

@end

@interface OTToursTableView : UITableView

@property (nonatomic, weak) id<OTToursTableViewDelegate> toursDelegate;

- (void)configureWithMapView:(MKMapView *)mapView;

- (void)addTours:(NSArray*)tours;
- (void)addTour:(OTTour*)tour;
- (void)removeTour:(OTTour*)tour;
- (void)removeAll;

- (void)addEntourages:(NSArray*)entourages;

@end
