//
//  OTTourMapHandler.m
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourMapHandler.h"
#import "OTTourPoint.h"

@implementation OTTourMapHandler

- (CLLocationCoordinate2D)startPoint {
    CLLocationCoordinate2D coordinate;
    if (self.tour.tourPoints.count) {
        OTTourPoint *startPoint = self.tour.tourPoints[0];
        coordinate = CLLocationCoordinate2DMake(startPoint.latitude, startPoint.longitude);
    }
    return coordinate;
}

- (id<MKAnnotation>)annotationFor:(CLLocationCoordinate2D)coordinate {
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    [annotation setCoordinate:coordinate];
    return annotation;
}

@end
