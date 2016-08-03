//
//  OTTourMapHandler.m
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourMapHandler.h"
#import "OTTourPoint.h"
#import "OTConsts.h"
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

- (MKPolyline *)lineData {
    if([self.tour.tourPoints count] < 1)
        return nil;
    CLLocationCoordinate2D coords[self.tour.tourPoints.count];
    int count = 0;
    for (OTTourPoint *point in self.tour.tourPoints)
        coords[count++] = point.toLocation.coordinate;
    return [MKPolyline polylineWithCoordinates:coords count:self.tour.tourPoints.count];

}

- (MKOverlayRenderer *)rendererFor:(MKPolyline *)line {
    MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:line];
    aRenderer.strokeColor = [OTTour colorForTourType:self.tour.type];
    aRenderer.lineWidth = MAP_TOUR_LINE_WIDTH;
    return aRenderer;
}

@end
