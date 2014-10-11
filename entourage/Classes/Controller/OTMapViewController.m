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
#import "OTEncounterAnnotation.h"

// Model
#import "OTPoi.h"
#import "OTEncounter.h"

// Service
#import "OTPoiService.h"

// Framework
#import <MapKit/MKMapView.h>
#import <WYPopoverController/WYPopoverController.h>
#import "KPClusteringController.h"
#import "KPAnnotation.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMapViewController () <MKMapViewDelegate, OTCalloutViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, strong) NSArray *encounters;

@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic, strong) KPClusteringController *clusteringController;
@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.mapView.delegate = self;
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];

	[self createMenuButton];

	self.title = NSLocalizedString(@"mapviewcontroller_title", @"");

	[[OTPoiService new] allPoisWithSuccess:^(NSArray *categories, NSArray *pois, NSArray *encounters)
	 {
		 [self.indicatorView setHidden:YES];

		 self.categories = categories;
		 self.pois = pois;
         self.encounters = encounters;

         [self feedMapViewWithPoiArray:pois];
         [self feedMapViewWithEncountersArray:encounters];
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

		[self.mapView addAnnotation:pointAnnotation];
	}

	[self computeAndSetCenterForPoiArray:array];
}

- (void)feedMapViewWithEncountersArray:(NSArray *)array
{
    NSMutableArray *annotations = [NSMutableArray new];
    for (OTEncounter *encounter in array)
    {
        OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
        [annotations addObject:pointAnnotation];
    }
    [self.clusteringController setAnnotations:annotations];
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
    MKAnnotationView *annotationView = nil;
    
	if ([annotation isKindOfClass:[OTCustomAnnotation class]])
	{
		annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kAnnotationIdentifier];

		if (!annotationView)
		{
			annotationView = ((OTCustomAnnotation *)annotation).annotationView;
		}
		annotationView.annotation = annotation;
    }
    else if ([annotation isKindOfClass:[KPAnnotation class]])
    {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)annotation;
        
        if ([kingpinAnnotation isCluster])
        {
            annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterClusterAnnotationIdentifier];
            if (!annotationView)
            {
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:kingpinAnnotation reuseIdentifier:kEncounterClusterAnnotationIdentifier];
            }
            MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)annotationView;

            pinAnnotationView.pinColor = MKPinAnnotationColorGreen;
        }
        else {
            id<MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
            if([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]])
            {
                annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterAnnotationIdentifier];
                if (!annotationView)
                {
                    annotationView = ((OTEncounterAnnotation *)simpleAnnontation).annotationView;
                }
                annotationView.annotation = simpleAnnontation;
            }
        }
        annotationView.canShowCallout = YES;
    }


	return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.clusteringController refresh:animated];
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
