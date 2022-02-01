//
//  OTEntourageMapHandler.m
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTEntourageMapHandler.h"
#import "OTEntourageRenderer.h"
#import "OTConsts.h"
#import "OTAppConfiguration.h"
#import "OTEntourageAnnotation.h"
#import "entourage-Swift.h"

@implementation OTEntourageMapHandler

- (CLLocationCoordinate2D)startPoint {
    return self.entourage.location.coordinate;
}

- (id<MKAnnotation>)annotationFor:(CLLocationCoordinate2D)coordinate {
    
    if ([OTAppConfiguration shouldShowMapHeatzoneForEntourage:self.entourage]) {
        return nil;
    }
    
    OTEntourageAnnotation *annotation = [[OTEntourageAnnotation alloc] initWithEntourage:self.entourage];
    return annotation;
}

- (id<MKOverlay>)newsFeedOverlayData {
    if ([OTAppConfiguration shouldShowMapHeatzoneForEntourage:self.entourage]) {
        return [MKCircle circleWithCenterCoordinate:self.entourage.location.coordinate
                                             radius:ENTOURAGE_RADIUS * ENTOURAGE_RADIUS_FACTOR];
    }

    return nil;
}

- (MKOverlayRenderer *)newsFeedOverlayRenderer:(id<MKOverlay>)overlay {
    if (![overlay isKindOfClass:[MKCircle class]]) {
        return nil;
    }
    
    return [[OTEntourageRenderer alloc] initWithOverlay:overlay];
}
@end
