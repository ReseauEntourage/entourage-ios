//
//  OTMapViewController.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

// Controller
#import "OTMapViewController.h"
#import "UIViewController+menu.h"

// View
#import "OTCustomAnnotation.h"

// Model
#import "OTPoi.h"

// Service
#import "OTPoiService.h"

// Framework
#import <MapKit/MKMapView.h>

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property(nonatomic, strong) NSArray *categories;
@property(nonatomic, strong) NSArray *pois;
@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.mapView.delegate = self;

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
		 UIAlertView *alertView = [[UIAlertView alloc]     initWithTitle:@"Erreur"
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
		OTCustomAnnotation *pointAnnotation = [[OTCustomAnnotation alloc] initWithPoi:poi];

		[[self mapView] addAnnotation:pointAnnotation];
	}

	[self computeAndSetCenterForPoiArray:array];
}

- (void)computeAndSetCenterForPoiArray:(NSArray *)array
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

/********************************************************************************/
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]])
	{
		return nil;
	}
	else if ([annotation isKindOfClass:[OTCustomAnnotation class]])
	{
		MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationIdentifier];

		if (annotationView)
		{
			annotationView.annotation = annotation;
		}
		else
		{
			annotationView = ((OTCustomAnnotation *)annotation).annotationView;
		}

		return annotationView;
	}

	return nil;
}

@end
