//
//  OTFeedsViewController.h
//  entourage
//
//  Created by Jr on 16/02/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTConfirmationViewController.h"
#import "OTEntourageEditorViewController.h"

@class MKMapView;
@class OTFeedItem;

@interface OTFeedsViewController : UIViewController <OTConfirmationViewControllerDelegate, EntourageEditorDelegate, UIGestureRecognizerDelegate>

// tour properties
@property (nonatomic, strong) OTFeedItem *selectedFeedItem;
@property (nonatomic) BOOL isFromEvent;
@property (nonatomic, strong) NSString *titleFrom;
@property (nonatomic) BOOL isFromNeoCourse;


- (void)zoomToCurrentLocation:(id)sender;
- (void)zoomMapToLocation:(CLLocation*)location;
- (void)willChangePosition;
- (void)didChangePosition;
- (void)reloadFeeds;

- (IBAction)showFilters;
- (void)switchToEvents;
- (void) showProposeFromNav;
@end
