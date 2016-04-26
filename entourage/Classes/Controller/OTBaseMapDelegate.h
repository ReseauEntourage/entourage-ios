//
//  OTBaseMapDelegate.h
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocationManager.h>

#import "OTMainViewController.h"

#define MAP_TOUR_LINE_WIDTH 4.0f

@interface OTBaseMapDelegate : NSObject

@property (nonatomic, weak) OTMainViewController* mapController;
@property (nonatomic) BOOL isActive;

- (instancetype)initWithMapController:(OTMainViewController *)mapController;

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;

- (CLLocationDistance)mapHeight:(MKMapView *)mapView;

@end
