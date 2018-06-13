//
//  OTEntourageMapHandler.m
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageMapHandler.h"
#import "OTEntourageRenderer.h"
#import "OTConsts.h"

@implementation OTEntourageMapHandler

- (CLLocationCoordinate2D)startPoint {
    return self.entourage.location.coordinate;
}

- (id<MKAnnotation>)annotationFor:(CLLocationCoordinate2D)coordinate {
    return nil;
}

- (id<MKOverlay>)newsFeedOverlayData {
    return [MKCircle circleWithCenterCoordinate:self.entourage.location.coordinate radius:ENTOURAGE_RADIUS * ENTOURAGE_RADIUS_FACTOR];
}

- (MKOverlayRenderer *)newsFeedOverlayRenderer:(id<MKOverlay>)overlay {
    if (![overlay isKindOfClass:[MKCircle class]]) {
        return nil;
    }
    
    return [[OTEntourageRenderer alloc] initWithOverlay:overlay];
}
@end
