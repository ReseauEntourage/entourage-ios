//
//  OTMapViewController.h
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTMeetingCalloutViewController.h"
#import "OTCreateMeetingViewController.h"
#import "OTConfirmationViewController.h"

@class MKMapView;
@class KPClusteringController;
@class OTEncounterAnnotation;
@class OTFeedItem;

@interface OTMainViewController : UIViewController <OTMeetingCalloutViewControllerDelegate, OTConfirmationViewControllerDelegate>

// tour properties
@property (nonatomic, strong) OTFeedItem *selectedFeedItem;
@property (nonatomic, strong) NSString *webview;

- (void)zoomToCurrentLocation:(id)sender;
- (void)willChangePosition;
- (void)didChangePosition;
- (void)reloadPois;
- (void)reloadFeeds;

- (void)editEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view;
- (void)displayPoiDetails:(MKAnnotationView *)view;

- (void)leaveGuide;
- (void)switchToGuide;
- (IBAction)showFilters;

@end
