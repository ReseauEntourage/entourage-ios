//
//  OTMapViewController.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <MapKit/MapKit.h>

// Controller
#import "OTMapViewController.h"
#import "UIViewController+menu.h"

#import "OTHTTPRequestManager.h"
#import "OTPoi.h"

@interface OTMapViewController ()

// UI
@property (nonatomic, strong) UIBarButtonItem *menuButton;

@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createMenuButton];
    
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

/**************************************************************************************************/
#pragma mark - Private methods

- (void)feedMapViewWithPoiArray:(NSArray *)array
{
    NSMutableArray *poiArray = [[NSMutableArray alloc] init];

    for (NSDictionary *dictionary in array) {
        OTPoi *poi = [OTPoi poiWithJSONDictionnary:dictionary];
        [poiArray addObject:poi];
        CLLocationCoordinate2D poiCoordinate = {.latitude =  poi.latitude, .longitude =  poi.longitude};

        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        pointAnnotation.coordinate = poiCoordinate;
        pointAnnotation.title = poi.name;
        pointAnnotation.subtitle = poi.type;

        [[self mapView] addAnnotation:pointAnnotation];
    }

    [self computeAndSetCenterForPoiArray:poiArray];
}

- (void)computeAndSetCenterForPoiArray:(NSMutableArray *)array {
    double maxLat = -MAXFLOAT;
    double maxLong = -MAXFLOAT;
    double minLat = MAXFLOAT;
    double minLong = MAXFLOAT;

    for (OTPoi *poi in array) {
        if (poi.latitude < minLat) {
            minLat = poi.latitude;
        }

        if (poi.longitude < minLong) {
            minLong = poi.longitude;
        }

        if (poi.latitude > maxLat) {
            maxLat = poi.latitude;
        }

        if (poi.longitude > maxLong) {
            maxLong = poi.longitude;
        }
    }

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat + minLat) * 0.5, (maxLong + minLong) * 0.5);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 10000, 10000);
    [[self mapView] setRegion:viewRegion animated:YES];
}



@end
