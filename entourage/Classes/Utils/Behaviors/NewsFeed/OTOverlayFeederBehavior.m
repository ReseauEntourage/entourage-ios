//
//  OTOverlayFeederBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOverlayFeederBehavior.h"
#import "OTFeedItem.h"
#import "OTFeedItemFactory.h"
#import <objc/runtime.h>

static char kAssociatedObjectKey;

@implementation OTOverlayFeederBehavior

- (void)addOverlays:(NSArray *)items {
    [self addOverlaysToMap:items];
}

- (void)updateOverlays:(NSArray *)items {
    [self.mapView removeOverlays:self.mapView.overlays];
    [self addOverlaysToMap:items];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    id object = objc_getAssociatedObject(overlay, &kAssociatedObjectKey);
    if([object isKindOfClass:[OTFeedItem class]]) {
        OTFeedItem *item = (OTFeedItem *)object;
        return [[[OTFeedItemFactory createFor:item] getMapHandler] newsFeedOverlayRenderer:overlay];
    }
    return nil;
}

#pragma mark - private methods

- (void)addOverlaysToMap:(NSArray *)items {
    for(OTFeedItem *item in items) {
        id<MKOverlay> overlay = [[[OTFeedItemFactory createFor:item] getMapHandler] newsFeedOverlayData];
        objc_setAssociatedObject(overlay, &kAssociatedObjectKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if([overlay isKindOfClass:[MKCircle class]])
            [self.mapView insertOverlay:overlay atIndex:0];
        else if([overlay isKindOfClass:[MKPolyline class]])
            [self.mapView addOverlay:overlay];
    }
}

@end
