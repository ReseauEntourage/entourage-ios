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

@interface OTMainViewController : UIViewController <OTMeetingCalloutViewControllerDelegate, OTCreateMeetingViewControllerDelegate, OTConfirmationViewControllerDelegate>


// tour properties
@property BOOL isTourRunning;
@property NSString *currentTourType;
@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, strong) OTFeedItem *selectedFeedItem;

@property (nonatomic, strong) KPClusteringController *clusteringController;

- (IBAction)zoomToCurrentLocation:(id)sender;
- (void)refreshMap;
- (void)didChangePosition;

- (void)displayEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view;
- (void)displayPoiDetails:(MKAnnotationView *)view;

@end
