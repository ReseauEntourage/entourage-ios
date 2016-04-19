//
//  OTBaseMapDelegate.h
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocationManager.h>

#import "OTMapViewController.h"

@interface OTBaseMapDelegate : NSObject

@property (nonatomic, weak) OTMapViewController* mapController;
@property (nonatomic) BOOL isActive;

- (instancetype)initWithMapController:(OTMapViewController *)mapController;

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;

- (CLLocationDistance)mapHeight:(MKMapView *)mapView;

@end
