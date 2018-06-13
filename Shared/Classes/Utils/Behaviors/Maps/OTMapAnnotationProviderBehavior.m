//
//  OTMapAnnotationProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMapAnnotationProviderBehavior.h"
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
    if (!CLLocationCoordinate2DIsValid(startPoint)) {
        return;
    }
    id<MKAnnotation> startAnnotation = [mapHandler annotationFor:startPoint];
    if (startAnnotation) {
        [self.map addAnnotation:[mapHandler annotationFor:startPoint]];
    }
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(startPoint, 1000, 1000)];
}

- (void)drawData {
    id<OTMapHandlerDelegate> mapHandler = [[OTFeedItemFactory createFor:self.feedItem] getMapHandler];
    id<MKOverlay> overlay = [mapHandler newsFeedOverlayData];
    if (overlay) {
        [self.map addOverlay:overlay];
    }
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return [[[OTFeedItemFactory createFor:self.feedItem] getMapHandler] newsFeedOverlayRenderer:overlay];
}

@end
