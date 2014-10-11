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

#import "NSUserDefaults+OT.h"

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

@property (nonatomic) BOOL isRegionSetted;

@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	CLLocationManager *locationManager = [[CLLocationManager alloc] init];
#ifdef __IPHONE_8_0
	if (IS_OS_8_OR_LATER)
	{
		// Use one or the other, not both. Depending on what you put in info.plist
		[locationManager requestWhenInUseAuthorization];
	}
#endif
	[locationManager startUpdatingLocation];

	self.mapView.showsUserLocation = YES;
	self.mapView.delegate = self;
	self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];

	[self zoomToCurrentLocation:nil];

	[self createMenuButton];

	self.title = NSLocalizedString(@"mapviewcontroller_title", @"");

	[self refreshMap];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self refreshMap];
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"currentUser"];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)registerObserver
{
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"currentUser" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)refreshMap
{
	if (!self.pois)
	{
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
			 [self registerObserver];
			 [self.indicatorView setHidden:YES];
		 }];
	}
}

- (void)feedMapViewWithPoiArray:(NSArray *)array
{
	for (OTPoi *poi in array)
	{
		OTCustomAnnotation *pointAnnotation = [[OTCustomAnnotation alloc] initWithPoi:poi];
		[self.mapView addAnnotation:pointAnnotation];
	}
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
		else
		{
			id<MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
			if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]])
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

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	if (!self.isRegionSetted)
	{
		self.isRegionSetted = YES;
		[self zoomToCurrentLocation:nil];
	}
}

/********************************************************************************/
#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover
{
	[self.popover dismissPopoverAnimated:YES];
}

/**************************************************************************************************/
#pragma mark - Actions


- (IBAction)zoomToCurrentLocation:(UIBarButtonItem *)sender
{
    float spanX = 0.0001;
    float spanY = 0.0001;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)createEncounter:(id)sender
{
    OTEncounter *encounter = [OTEncounter new];
    encounter.date = [NSDate date];
    encounter.message = @"foo";
    encounter.streetPersonName =  @"bar";
    encounter.latitude = self.mapView.region.center.latitude;
    encounter.longitude = self.mapView.region.center.longitude;
    [[OTPoiService new] sendEncounter:encounter withSuccess:^{
        
    } failure:^(NSError *error) {
        
    }];
}

@end
