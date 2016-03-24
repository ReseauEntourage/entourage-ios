//
//  UIViewController+MapView.h
//  entourage
//
//  Created by Ciprian Habuc on 23/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKMapView.h>
#import <CoreLocation/CoreLocation.h>

@interface UIViewController (MapView)
<
    MKMapViewDelegate,
    CLLocationManagerDelegate
>

- (void)startLocationUpdatesWithLocationManager:(CLLocationManager *)locationManager;

@end

