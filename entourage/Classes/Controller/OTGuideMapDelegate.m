//
//  OTGuideMapDelegate.m
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGuideMapDelegate.h"

#import "KPClusteringController.h"
#import "KPAnnotation.h"
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
    MKZoomScale currentZoomScale = mapView.bounds.size.width / mapView.visibleMapRect.size.width;
    
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingPinAnnotation = (KPAnnotation *)annotation;
        
        if (currentZoomScale < 0.244113 && kingPinAnnotation.isCluster) {
            annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
            if (annotationView == nil) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:kingPinAnnotation reuseIdentifier:@"cluster"];
                annotationView.image = [UIImage imageNamed:@"poi_cluster"];
                kingPinAnnotation.title = [NSString stringWithFormat:@"%lu", (unsigned long)kingPinAnnotation.annotations.count];
            }
        }
        else {
            OTCustomAnnotation *customAnnotation = (OTCustomAnnotation *)kingPinAnnotation.annotations.anyObject;
            annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:customAnnotation.annotationIdentifier];
            
            if (!annotationView) {
                annotationView = customAnnotation.annotationView;
            }
            annotationView.annotation = annotation;
        }
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView *view in views) {
        id<MKAnnotation> annotation = [view annotation];
        if ([annotation isKindOfClass:[KPAnnotation class]]) {
            KPAnnotation *kpAnnotation = (KPAnnotation *)annotation;
            if (kpAnnotation.isCluster) {
                if ([view subviews].count != 0) {
                    UIView *subview = [[view subviews] objectAtIndex:0];
                    [subview removeFromSuperview];
                }
                CGRect viewRect = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
                UILabel *count = [[UILabel alloc] initWithFrame:viewRect];
                count.text = [NSString stringWithFormat:@"%lu", (unsigned long)kpAnnotation.annotations.count];
                count.textColor = [UIColor whiteColor];
                count.textAlignment = NSTextAlignmentCenter;
                [view addSubview:count];
            }
        }
    }
    [mapView setNeedsDisplay];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.mapController.clusteringController refresh:animated];
    
    CLLocationDistance distance = (MKMetersBetweenMapPoints(MKMapPointForCoordinate(_currentMapCenter), MKMapPointForCoordinate(mapView.centerCoordinate))) / 1000.0f;
    if (distance > [self mapHeight:mapView]) {
        [self.mapController refreshMap];
        self.currentMapCenter = mapView.centerCoordinate;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    MKZoomScale currentZoomScale = mapView.bounds.size.width / mapView.visibleMapRect.size.width;
    
    KPAnnotation *kpAnnotation = view.annotation;
    if (currentZoomScale > 0.244113) {
        [self.mapController displayPoiDetails:view];
    }
    else if (!kpAnnotation.isCluster) {
        [self.mapController displayPoiDetails:view];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [self.mapController zoomToCurrentLocation:nil];
}

@end
