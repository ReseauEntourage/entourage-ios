//
//  OTMapViewController.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "OTMapViewController.h"
#import "OTHTTPRequestManager.h"
#import "OTPoi.h"

@interface OTMapViewController ()

@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[OTHTTPRequestManager sharedInstance] GET:kAPIPoiRoute parameters:nil
        success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            [self.indicatorView setHidden:TRUE];
            NSArray *poiArray = responseObject;
            [self feedMapViewWithPoiArray:poiArray];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                                               message:@"Impossible de récupérer les POI"
                                                              delegate:nil
                                                     cancelButtonTitle:@"Dommage :("
                                                     otherButtonTitles:nil];
            [self.indicatorView setHidden:TRUE];
            [alertView show];
        }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 48.870535;
    zoomLocation.longitude= 2.307400;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10, 10);

    [[self mapView] setRegion:viewRegion animated:YES];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)feedMapViewWithPoiArray:(NSArray *)array
{
    for (NSDictionary *dictionary in array) {
        OTPoi *poi = [OTPoi poiWithJSONDictionnary:dictionary];
        CLLocationCoordinate2D poiCoordinate = {latitude: poi.latitude, longitude: poi.longitude};

        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        pointAnnotation.coordinate = poiCoordinate;
        pointAnnotation.title = poi.name;
        pointAnnotation.subtitle = poi.type;

        [[self mapView] addAnnotation:pointAnnotation];
    }
}


@end
