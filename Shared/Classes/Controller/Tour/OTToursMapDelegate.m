//
//  OTNewsfeedMapDelegate.m
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTToursMapDelegate.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "OTTour.h"
#import "OTTourService.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "OTOngoingTourService.h"
#import "OTStartTourAnnotation.h"
#import "OTEntourageAnnotation.h"
#import "OTNeighborhoodAnnotation.h"
#import "OTPrivateCircleAnnotation.h"
#import "OTOutingAnnotation.h"

@implementation OTToursMapDelegate

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
    MKAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[OTEncounterAnnotation class]]) {
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterAnnotationIdentifier];
        if (!annotationView) {
            annotationView = ((OTEncounterAnnotation *)annotation).annotationView;
        }
        annotationView.annotation = annotation;
        annotationView.canShowCallout = YES;
    }
    else if ([annotation isKindOfClass:[OTStartTourAnnotation class]]) {
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kStartTourAnnotationIdentifier];
        if (!annotationView)
            annotationView = ((OTStartTourAnnotation *)annotation).annotationView;
        annotationView.annotation = annotation;
        annotationView.canShowCallout = NO;
    }
    else if ([annotation isKindOfClass:[OTPrivateCircleAnnotation class]]) {
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kPrivateCircleAnnotationIdentifier];
        if (!annotationView) {
            annotationView = ((OTPrivateCircleAnnotation *)annotation).annotationView;
        }
        annotationView.annotation = annotation;
        annotationView.canShowCallout = NO;
    }
    else if ([annotation isKindOfClass:[OTNeighborhoodAnnotation class]]) {
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kNeighborhoodAnnotationIdentifier];
        if (!annotationView) {
            annotationView = ((OTNeighborhoodAnnotation *)annotation).annotationView;
        }
        annotationView.annotation = annotation;
        annotationView.canShowCallout = NO;
    }
    else if ([annotation isKindOfClass:[OTOutingAnnotation class]]) {
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kOutingAnnotationIdentifier];
        if (!annotationView) {
            annotationView = ((OTOutingAnnotation *)annotation).annotationView;
        }
        annotationView.annotation = annotation;
        annotationView.canShowCallout = NO;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.mapController didChangePosition];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self.mapController willChangePosition];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    
    if ([view.annotation isKindOfClass:[OTEncounterAnnotation class]]) {
        [self.mapController editEncounter:(OTEncounterAnnotation *)view.annotation withView:(MKAnnotationView *)view];
    }
}

@end
