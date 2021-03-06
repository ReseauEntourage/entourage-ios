//
//  OTCreateMeetingViewController.h
//  entourage
//
//  Created by Hugo Schouman on 11/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

@class OTEncounter;

@protocol OTCreateMeetingViewControllerDelegate

- (void)encounterSent:(OTEncounter *)encounter;

@end

@interface OTCreateMeetingViewController : UIViewController

@property (nonatomic, weak) id<OTCreateMeetingViewControllerDelegate> delegate;
@property (nonatomic, strong) OTEncounter *encounter;
@property (strong, nonatomic) NSNumber *currentTourId;
@property (nonatomic) BOOL displayedOnceForTour;

- (void)configureWithTourId:(NSNumber *)currentTourId andLocation:(CLLocationCoordinate2D)location;

@end
