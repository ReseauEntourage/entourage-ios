//
//  OTGuideMapDelegate.m
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGuideMapDelegate.h"
#import "OTCustomAnnotation.h"

@interface OTGuideMapDelegate ()

@property (nonatomic) CLLocationCoordinate2D currentMapCenter;

@end

@implementation OTGuideMapDelegate

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setIsActive:(BOOL)isActive
{
    [super setIsActive:isActive];
    if (isActive) {
        self.currentMapCenter = CLLocationCoordinate2DMake(0, 0);
    }
}

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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLLocationDistance distance = (MKMetersBetweenMapPoints(MKMapPointForCoordinate(_currentMapCenter), MKMapPointForCoordinate(mapView.centerCoordinate))) / 1000.0f;
    if (distance > [self mapHeight:mapView]) {
        [self.mapController getData:NO];
        self.currentMapCenter = mapView.centerCoordinate;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    if([view.annotation isKindOfClass:[OTCustomAnnotation class]])
        [self.mapController displayPoiDetails:view];
}

@end
