//
//  OTEntourageMapHandler.m
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageMapHandler.h"
#import "OTEntourageAnnotation.h"

@implementation OTEntourageMapHandler

- (CLLocationCoordinate2D)startPoint {
    return self.entourage.location.coordinate;
}

- (id<MKAnnotation>)annotationFor:(CLLocationCoordinate2D)coordinate {
    return [[OTEntourageAnnotation alloc] initWithEntourage:self.entourage];
}

- (MKPolyline *)lineData {
    return nil;
}

- (MKOverlayRenderer *)rendererFor:(MKPolyline *)line {
    return nil;
}

@end
