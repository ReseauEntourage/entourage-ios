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

#import <MapKit/MKMapView.h>

@interface OTMapViewController () <MKMapViewDelegate>

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
		CLLocationCoordinate2D poiCoordinate = { .latitude =  poi.latitude, .longitude =  poi.longitude };

		MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
		pointAnnotation.coordinate = poiCoordinate;
		pointAnnotation.title = poi.name;
		pointAnnotation.subtitle = poi.details;

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
	else
	{
		MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"identifier"];
		[view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picto_category-1"]]];
		return view;
//
//
//		static NSString *const identifier = @"MyCustomAnnotation";
//
//		MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//
//		if (annotationView)
//		{
//			annotationView.annotation = annotation;
//		}
//		else
//		{
//			annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
//														  reuseIdentifier:identifier];
//		}
//
//		// set your annotationView properties
//
//		annotationView.image = [UIImage imageNamed:@"Your image here"];
//		annotationView.canShowCallout = YES;
//
//		// if you add QuartzCore to your project, you can set shadows for your image, too
//		//
//		// [annotationView.layer setShadowColor:[UIColor blackColor].CGColor];
//		// [annotationView.layer setShadowOpacity:1.0f];
//		// [annotationView.layer setShadowRadius:5.0f];
//		// [annotationView.layer setShadowOffset:CGSizeMake(0, 0)];
//		// [annotationView setBackgroundColor:[UIColor whiteColor]];
//
//		return annotationView;
	}

	return nil;
}

@end
