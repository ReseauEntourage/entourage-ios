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

#import "OTPoi.h"
#import "OTPoiService.h"

@interface OTMapViewController ()

@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) UIBarButtonItem *menuButton;

@property(nonatomic, strong) NSArray *categories;
@property(nonatomic, strong) NSArray *pois;
@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createMenuButton];

    self.title = NSLocalizedString(@"mapviewcontroller_title", @"");

    [[OTPoiService new] allPoisWithSuccess:^(NSArray *categories, NSArray *pois)
            {
                [self.indicatorView setHidden:YES];

                self.categories = categories;
                self.pois = pois;

                [self feedMapViewWithPoiArray:pois];
            }
            failure:^(NSError *error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Erreur"
                        message:@"Impossible de récupérer les POI"
                        delegate:nil
                        cancelButtonTitle:@"Dommage :("
                        otherButtonTitles:nil];
                [self.indicatorView setHidden:YES];
                [alertView show];
            }];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)feedMapViewWithPoiArray:(NSArray *)array
{
    for (OTPoi *poi in array)
    {
        CLLocationCoordinate2D poiCoordinate = {.latitude =  poi.latitude, .longitude =  poi.longitude};

        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        pointAnnotation.coordinate = poiCoordinate;
        pointAnnotation.title = poi.name;
        pointAnnotation.subtitle = poi.details;

        [[self mapView] addAnnotation:pointAnnotation];
    }

    [self computeAndSetCenterForPoiArray:array];
}

- (void)computeAndSetCenterForPoiArray:(NSMutableArray *)array
{
    double maxLat = -MAXFLOAT;
    double maxLong = -MAXFLOAT;
    double minLat = MAXFLOAT;
    double minLong = MAXFLOAT;

    for (OTPoi *poi in array)
    {
        if (poi.latitude < minLat)
        {
            minLat = poi.latitude;
        }

        if (poi.longitude < minLong)
        {
            minLong = poi.longitude;
        }

        if (poi.latitude > maxLat)
        {
            maxLat = poi.latitude;
        }

        if (poi.longitude > maxLong)
        {
            maxLong = poi.longitude;
        }
    }

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat + minLat) * 0.5, (maxLong + minLong) * 0.5);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 10000, 10000);
    [[self mapView] setRegion:viewRegion animated:YES];
}

@end
