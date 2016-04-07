//
//  OTBaseMapDelegate.m
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBaseMapDelegate.h"

@implementation OTBaseMapDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

- (CLLocationDistance)mapHeight:(MKMapView *)mapView {
    MKMapPoint mpTopRight = MKMapPointMake(mapView.visibleMapRect.origin.x + mapView.visibleMapRect.size.width,
                                           mapView.visibleMapRect.origin.y);
    
    MKMapPoint mpBottomRight = MKMapPointMake(mapView.visibleMapRect.origin.x + mapView.visibleMapRect.size.width,
                                              mapView.visibleMapRect.origin.y + mapView.visibleMapRect.size.height);
    
    CLLocationDistance vDist = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight) / 1000.f;
    
    return vDist;
}

@end
