//
//  OTFeedToursViewController.h
//  entourage
//
//  Created by Jr on 17/02/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OTConfirmationViewController.h"

@class MKMapView;
@class OTEncounterAnnotation;
@class OTFeedItem;
NS_ASSUME_NONNULL_BEGIN

@interface OTFeedToursViewController : UIViewController <OTConfirmationViewControllerDelegate, UIGestureRecognizerDelegate>

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
- (void) showProposeFromNav;
- (void) createTourFromNav;
- (void) createEncounterFromNav;
- (void)createQuickEncounter;
@end


NS_ASSUME_NONNULL_END
