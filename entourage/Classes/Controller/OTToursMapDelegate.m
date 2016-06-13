//
//  OTNewsfeedMapDelegate.m
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTToursMapDelegate.h"
#import "KPAnnotation.h"
#import "KPClusteringController.h"
#import "JSBadgeView.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "OTEntourageAnnotation.h"
#import "OTTour.h"
#import "OTTourService.h"
#import "UIColor+entourage.h"
#import "UIImage+entourage.h"

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
    
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)annotation;
        
        if ([kingpinAnnotation isCluster])
        {
            JSBadgeView *badgeView;
            
            
            id firstAnnotation = kingpinAnnotation.annotations.allObjects.firstObject;
            NSString *annotationViewIdentifier = kEncounterAnnotationIdentifier;
            NSString *annotationImageName = @"report";
            JSBadgeViewAlignment badgeAlignament = JSBadgeViewAlignmentBottomCenter;
            if ([firstAnnotation isKindOfClass:[OTEntourageAnnotation class]]) {
                annotationViewIdentifier = kEntourageAnnotationIdentifier;
                annotationImageName = @"heatZone";
                badgeAlignament = JSBadgeViewAlignmentCenter;
            }
            
            annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
            if (!annotationView)
            {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:kingpinAnnotation reuseIdentifier:nil];
                annotationView.canShowCallout = NO;
                UIImage *scaledImage = [UIImage imageNamed:@"heatZone"
                                                 withScale:self.mapController.entourageScale];
                annotationView.image = scaledImage;
                badgeView = [[JSBadgeView alloc] initWithParentView:annotationView alignment:badgeAlignament];
            }
            else
            {
                for (UIView *subview in annotationView.subviews) {
                    if ([subview isKindOfClass:JSBadgeView.class]) {
                        badgeView = (JSBadgeView *)subview;
                    }
                }
            }
            badgeView.badgeText = [NSString stringWithFormat:@"%lu", (unsigned long)kingpinAnnotation.annotations.count];
        }
        else
        {
            id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
            if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]]) {
                annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterAnnotationIdentifier];
                if (!annotationView) {
                    annotationView = ((OTEncounterAnnotation *)simpleAnnontation).annotationView;
                }
                annotationView.annotation = simpleAnnontation;
            } else if ([simpleAnnontation isKindOfClass:[OTEntourageAnnotation class]]) {
                annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEntourageAnnotationIdentifier];
                if (!annotationView) {
                    annotationView = ((OTEntourageAnnotation *)simpleAnnontation).annotationView;
                }
                annotationView.annotation = simpleAnnontation;
            }
        }
        annotationView.canShowCallout = YES;
    }
    
    
    return annotationView;
}



- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.mapController.clusteringController refresh:animated];
    //NSLog(@"region did change");
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
    
    if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)view.annotation;
        if ([kingpinAnnotation isCluster]) {
            // Do nothing
        }
        else {
            id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
            if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]]) {
                [self.mapController displayEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view];
            }
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = (MKPolyline *) overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];

        OTTour *tour = [self.drawnTours objectForKey:polyline];
        //NSLog(@"%d TOUR-TYPE %@", tour.sid.intValue, tour.tourType);
        aRenderer.strokeColor = [OTTour colorForTourType:tour.type];
        if (self.mapController.isTourRunning && tour == nil) {
            aRenderer.strokeColor = [OTTour colorForTourType:self.mapController.currentTourType];
        }
        aRenderer.lineWidth = MAP_TOUR_LINE_WIDTH;
        return aRenderer;
    }
    return nil;
}

@end
