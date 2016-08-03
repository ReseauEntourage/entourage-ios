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

@end

@implementation OTMapAnnotationProviderBehavior

- (void)configureWith:(OTFeedItem *)feedItem {
    self.map.delegate = self;
    id<OTMapHandlerDelegate> mapHandler = [[OTFeedItemFactory createFor:feedItem] getMapHandler];
    CLLocationCoordinate2D startPoint = [mapHandler startPoint];
    [self.map addAnnotation:[mapHandler annotationFor:startPoint]];
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(startPoint, 1000, 1000)];
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

@end
