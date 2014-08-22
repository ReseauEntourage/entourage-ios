//
//  OTMapViewController.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "OTMapViewController.h"

@interface OTMapViewController ()

@end

@implementation OTMapViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 48.870535;
    zoomLocation.longitude= 2.307400;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10, 10);

    [[self mapView] setRegion:viewRegion animated:YES];
}


@end
