//
//  OTMapAnnotationProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMapAnnotationProviderBehavior.h"
#import "OTEntourageAnnotation.h"
#import "OTEntourageAnnotationView.h"
#import "OTFeedItemFactory.h"
#import "OTMapHandlerDelegate.h"

@interface OTMapAnnotationProviderBehavior () <MKMapViewDelegate>

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTMapAnnotationProviderBehavior

- (void)configureWith:(OTFeedItem *)feedItem {
    self.map.delegate = self;
    self.feedItem = feedItem;
}

- (void)addStartPoint {
    id<OTMapHandlerDelegate> mapHandler = [[OTFeedItemFactory createFor:self.feedItem] getMapHandler];
    CLLocationCoordinate2D startPoint = [mapHandler startPoint];
    [self.map addAnnotation:[mapHandler annotationFor:startPoint]];
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(startPoint, 1000, 1000)];
}

- (void)drawData {
    id<OTMapHandlerDelegate> mapHandler = [[OTFeedItemFactory createFor:self.feedItem] getMapHandler];
    MKPolyline *polyline = [mapHandler lineData];
    if(polyline)
        [self.map addOverlay:polyline];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(nonnull id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[OTEntourageAnnotation class]]) {
        OTEntourageAnnotation *entAnnotation = (OTEntourageAnnotation*)annotation;
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEntourageAnnotationIdentifier];
        if(annotationView ) {
            OTEntourageAnnotationView *entAnnotationView = (OTEntourageAnnotationView *)annotationView;
            entAnnotationView.annotation = entAnnotation;
            [entAnnotationView updateScale:entAnnotation.scale];
        }
        else
            annotationView = [[OTEntourageAnnotationView alloc] initWithAnnotation:entAnnotation reuseIdentifier:kEntourageAnnotationIdentifier andScale:entAnnotation.scale];
        return annotationView;
    } else {
        return nil;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = (MKPolyline *) overlay;
        return [[[OTFeedItemFactory createFor:self.feedItem] getMapHandler] rendererFor:polyline];
    }
    return nil;
}

@end
