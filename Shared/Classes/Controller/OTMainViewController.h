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
#import "OTEntourageEditorViewController.h"

@class MKMapView;
@class KPClusteringController;
@class OTEncounterAnnotation;
@class OTFeedItem;

@interface OTMainViewController : UIViewController <OTConfirmationViewControllerDelegate, EntourageEditorDelegate, UIGestureRecognizerDelegate>

// tour properties
@property (nonatomic, strong) OTFeedItem *selectedFeedItem;
@property (nonatomic, strong) NSString *webview;

- (void)zoomToCurrentLocation:(id)sender;
- (void)zoomMapToLocation:(CLLocation*)location;
- (void)willChangePosition;
- (void)didChangePosition;
- (void)reloadFeeds;

- (void)editEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view;

- (IBAction)showFilters;
- (void)switchToEvents;
- (void) showProposeFromNav;
- (void) createTourFromNav;
- (void) createEncounterFromNav;
- (void)createQuickEncounter;
@end
