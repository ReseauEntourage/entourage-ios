//
//  OTGuideMapDelegate.m
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGuideMapDelegate.h"
#import "OTCustomAnnotation.h"

@implementation OTGuideMapDelegate

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
    MKAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[OTCustomAnnotation class]]) {
        OTCustomAnnotation *customAnnotation = (OTCustomAnnotation *)annotation;
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:customAnnotation.annotationIdentifier];
        if (!annotationView)
            annotationView = customAnnotation.annotationView;
        annotationView.annotation = annotation;
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self.mapController willChangePosition];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.mapController didChangePosition];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    if([view.annotation isKindOfClass:[OTCustomAnnotation class]])
        [self.mapController displayPoiDetails:view];
}

@end
