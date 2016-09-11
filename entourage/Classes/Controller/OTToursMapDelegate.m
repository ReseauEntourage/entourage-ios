//
//  OTNewsfeedMapDelegate.m
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTToursMapDelegate.h"
#import "JSBadgeView.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "OTTour.h"
#import "OTTourService.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTOngoingTourService.h"

@interface OTToursMapDelegate ()

@property (nonatomic) BOOL mapWasCenteredOnUserLocation;

@end

@implementation OTToursMapDelegate

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mapWasCenteredOnUserLocation = NO;
        self.isActive = NO;
    }
    return self;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
    MKAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[OTEncounterAnnotation class]]) {
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterAnnotationIdentifier];
        if (!annotationView)
            annotationView = ((OTEncounterAnnotation *)annotation).annotationView;
        annotationView.annotation = annotation;
    }
    annotationView.canShowCallout = YES;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.mapController didChangePosition];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.mapWasCenteredOnUserLocation) {
        [self.mapController zoomToCurrentLocation:nil];
        self.mapWasCenteredOnUserLocation = YES;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    if ([view.annotation isKindOfClass:[OTEncounterAnnotation class]])
        [self.mapController displayEncounter:(OTEncounterAnnotation *)view.annotation withView:(MKAnnotationView *)view];
}

@end
