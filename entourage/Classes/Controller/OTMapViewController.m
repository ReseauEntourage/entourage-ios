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
#import "OTCalloutViewController.h"

// View
#import "OTCustomAnnotation.h"

// Model
#import "OTPoi.h"

// Service
#import "OTPoiService.h"

// Framework
#import <MapKit/MKMapView.h>
#import <WYPopoverController/WYPopoverController.h>

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMapViewController () <MKMapViewDelegate, OTCalloutViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *pois;

@property (nonatomic, strong) WYPopoverController *popover;
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

		if (!annotationView)
		{
			annotationView = ((OTCustomAnnotation *)annotation).annotationView;
		}
		annotationView.annotation = annotation;
		return annotationView;
	}

	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	[mapView deselectAnnotation:view.annotation animated:NO];

	if ([view.annotation isKindOfClass:[OTCustomAnnotation class]])
	{
		// Start up our view controller from a Storyboard
		OTCalloutViewController *controller = (OTCalloutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OTCalloutViewController"];
		controller.delegate = self;

		UIView *popView = [controller view];

		popView.frame = CGRectOffset(view.frame, .0f, CGRectGetHeight(popView.frame) + 10000.f);

		[UIView animateWithDuration:.3f
						 animations:^
		 {
			 popView.frame = CGRectOffset(popView.frame, .0f, -CGRectGetHeight(popView.frame));
		 }];

		OTCustomAnnotation *annotation = [((MKAnnotationView *)view)annotation];

		[controller configureWithPoi:annotation.poi];

		self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
		[self.popover setTheme:[WYPopoverTheme themeForIOS7]];

		[self.popover presentPopoverFromRect:view.bounds
									  inView:view
					permittedArrowDirections:WYPopoverArrowDirectionNone
									animated:YES
									 options:WYPopoverAnimationOptionFadeWithScale];
	}
}

/********************************************************************************/
#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover
{
	[self.popover dismissPopoverAnimated:YES];
}

@end
