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
#import "OTMeetingCalloutViewController.h"
#import "OTCreateMeetingViewController.h"

// View
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "JSBadgeView.h"

// Model
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTEncounter.h"

// Service
#import "OTTourService.h"

// Framework
#import <MapKit/MapKit.h>
#import <MapKit/MKMapView.h>
#import <CoreLocation/CoreLocation.h>
#import <WYPopoverController/WYPopoverController.h>
#import "KPClusteringController.h"
#import "KPAnnotation.h"

// User
#import "NSUserDefaults+OT.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMapViewController () <MKMapViewDelegate, OTMeetingCalloutViewControllerDelegate, CLLocationManagerDelegate>

// map

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// markers

@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic, strong) KPClusteringController *clusteringController;
@property (nonatomic) BOOL isRegionSetted;

// tour

@property BOOL isTourRunning;
@property int seconds;
@property float distance;
@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *pointsToSend;

// tour lifecycle

@property (nonatomic, weak) IBOutlet UIView *launcherView;
@property (nonatomic, weak) IBOutlet UIButton *launcherButton;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *createEncounterButton;

// launcher

@property (nonatomic, weak) IBOutlet UIButton *feetButton;
@property (nonatomic, weak) IBOutlet UIButton *carButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *typeButtons;

// tours

@property (nonatomic, strong) NSMutableArray *tours;

@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.pointsToSend = [NSMutableArray new];
    self.encounters = [NSMutableArray new];
    
	_locationManager = [[CLLocationManager alloc] init];
	if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[self.locationManager requestWhenInUseAuthorization];
	}
	[self.locationManager startUpdatingLocation];

	self.mapView.showsUserLocation = YES;
	self.mapView.delegate = self;
	self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
	[self zoomToCurrentLocation:nil];
	[self createMenuButton];
	[self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[self refreshMap];
    
    self.launcherView.hidden = YES;
    if (self.isTourRunning) {
        self.launcherButton.hidden = YES;
        self.createEncounterButton.hidden = NO;
        self.stopButton.hidden = NO;
        [self feedMapViewWithEncounters];
    }
    else {
        self.stopButton.hidden = YES;
        self.createEncounterButton.hidden = YES;
    }
    [self startLocationUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self refreshMap];
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)configureView {
	self.title = NSLocalizedString(@"mapviewcontroller_title", @"");
}

- (void)registerObserver {
	[[NSUserDefaults standardUserDefaults] addObserver:self
	                                        forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")
	                                           options:NSKeyValueObservingOptionNew
	                                           context:nil];
}

- (void)refreshMap {
    [[OTTourService new] toursAroundCoordinate:self.mapView.centerCoordinate
                                         limit:@10
                                      distance:[self mapHeight]
                                       success:^(NSMutableArray *closeTours)
                                        {
                                            [self.indicatorView setHidden:YES];
                                            self.tours = closeTours;
                                            [self feedMapViewWithTours];
                                        }
                                       failure:^(NSError *error) {
                                            [self registerObserver];
                                            [self.indicatorView setHidden:YES];
                                        }];
}

- (CLLocationDistance)mapHeight {
	MKMapPoint mpTopRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
	                                       self.mapView.visibleMapRect.origin.y);

	MKMapPoint mpBottomRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
	                                          self.mapView.visibleMapRect.origin.y + self.mapView.visibleMapRect.size.height);

	CLLocationDistance vDist = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight) / 1000.f;

	return vDist;
}

- (void)feedMapViewWithEncounters {
	NSMutableArray *annotations = [NSMutableArray new];

	for (OTEncounter *encounter in self.encounters) {
		OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
		[annotations addObject:pointAnnotation];
	}
	[self.clusteringController setAnnotations:annotations];
}

- (void)feedMapViewWithTours {
    for (OTTour *tour in self.tours) {
        [self drawTour:tour];
    }
}

- (void)drawTour:(OTTour *)tour {
    CLLocationCoordinate2D coords[[tour.tourPoints count]];
    int count = 0;
    for (OTTourPoint *point in tour.tourPoints) {
        coords[count++] = point.toLocation.coordinate;
    }
    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:[tour.tourPoints count]]];
}

- (NSArray *)filterCurrentAnnotations:(NSSet *)annots {
    // Since POIs moved to another controller, check necessary ?
	NSMutableArray *annotationsToAdd = [[NSMutableArray alloc] init];

	for (id a in[annots allObjects]) {
		if ([a isKindOfClass:[KPAnnotation class]]) {
			for (id e in[a annotations]) {
				if ([e isKindOfClass:[OTEncounterAnnotation class]]) {
					[annotationsToAdd addObject:e];
				}
			}
		}
	}

	return annotationsToAdd;
}

- (NSString *)encounterAnnotationToString:(OTEncounterAnnotation *)annotation {
	OTEncounter *encounter = [annotation encounter];
	NSString *cellTitle = [NSString stringWithFormat:@"%@ a rencontré %@",
	                       encounter.userName,
	                       encounter.streetPersonName];

	return cellTitle;
}

- (void)displayEncounter:(OTEncounterAnnotation *)simpleAnnontation {
	OTMeetingCalloutViewController *controller = (OTMeetingCalloutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OTMeetingCalloutViewController"];
	controller.delegate = self;

	OTEncounterAnnotation *encounterAnnotation = (OTEncounterAnnotation *)simpleAnnontation;
	OTEncounter *encounter = encounterAnnotation.encounter;
	[self presentViewController:controller animated:YES completion:nil];
	[controller configureWithEncouter:encounter];


	[Flurry logEvent:@"Open_Encounter_From_Map" withParameters:@{ @"encounter_id" : encounterAnnotation.encounter.sid }];
}

- (void)eachSecond {
    self.seconds++;
    /*
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@", [MathController stringifySecondCount:self.seconds usingLongFormat:NO]];
    self.distLabel.text = [NSString stringWithFormat:@"Distance: %@", [MathController stringifyDistance:self.distance]];
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@", [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
     */
}

- (void)sendTour {
    [[OTTourService new] sendTour:self.tour withSuccess:^(OTTour *sentTour) {
        self.tour.sid = sentTour.sid;
        NSLog(@"send tour success");
    } failure:^(NSError *error) {
    }];
}

- (void)closeTour {
    [[OTTourService new] closeTour:self.tour withSuccess:^(OTTour *closedTour) {
        [self clearMap];
                NSLog(@"close tour success");
    } failure:^(NSError *error) {
    }];
}

- (void)sendTourPoints:(NSMutableArray *)tourPoint {
    [[OTTourService new] sendTourPoint:tourPoint withTourId:self.tour.sid withSuccess:^(OTTour *updatedTour) {
                NSLog(@"send point success");
    } failure:^(NSError *error) {
    }];
}

/********************************************************************************/
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
	MKAnnotationView *annotationView = nil;

    if ([annotation isKindOfClass:[KPAnnotation class]]) {
		KPAnnotation *kingpinAnnotation = (KPAnnotation *)annotation;

		if ([kingpinAnnotation isCluster]) {
			JSBadgeView *badgeView;
			annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterClusterAnnotationIdentifier];
			if (!annotationView) {
				annotationView = [[MKAnnotationView alloc] initWithAnnotation:kingpinAnnotation reuseIdentifier:kEncounterClusterAnnotationIdentifier];
				annotationView.canShowCallout = NO;
				annotationView.image = [UIImage imageNamed:@"rencontre.png"];
				badgeView = [[JSBadgeView alloc] initWithParentView:annotationView alignment:JSBadgeViewAlignmentBottomCenter];
			}
			else {
				for (UIView *subview in annotationView.subviews) {
					if ([subview isKindOfClass:JSBadgeView.class]) {
						badgeView = (JSBadgeView *)subview;
					}
				}
			}
			badgeView.badgeText = [NSString stringWithFormat:@"%lu", (unsigned long)kingpinAnnotation.annotations.count];
		}
		else {
			id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
			if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]]) {
				annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterAnnotationIdentifier];
				if (!annotationView) {
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
	[self refreshMap];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	[mapView deselectAnnotation:view.annotation animated:NO];

    if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
		KPAnnotation *kingpinAnnotation = (KPAnnotation *)view.annotation;
		if ([kingpinAnnotation isCluster]) {
			// Do nothing
		}
		else {
			id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
			if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]]) {
				[self displayEncounter:(OTEncounterAnnotation *)simpleAnnontation];
			}
		}
	}
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	if (!self.isRegionSetted) {
		self.isRegionSetted = YES;
		[self zoomToCurrentLocation:nil];
	}
}

- (void)startLocationUpdates {
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    self.locationManager.distanceFilter = 5; // meters
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
            
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
        
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [self.mapView setRegion:region animated:YES];
            
                if (self.isTourRunning) {
                    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
                    OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:newLocation];
                    [self.tour.tourPoints addObject:tourPoint];
                    [self.pointsToSend addObject:tourPoint];
                    [self sendTourPoints:self.pointsToSend];
                    [self.pointsToSend removeLastObject];
                }
            }
        
            [self.locations addObject:newLocation];
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = (MKPolyline *) overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];
        aRenderer.strokeColor = [UIColor blueColor];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

- (void)clearMap {
    [self.mapView removeOverlays:[self.mapView overlays]];
    [self.clusteringController setAnnotations:nil];
}

/********************************************************************************/
#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover {
	[self.popover dismissPopoverAnimated:YES];
}

/********************************************************************************/
#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OTCreateMeeting"]) {
        OTCreateMeetingViewController *controller = (OTCreateMeetingViewController *)segue.destinationViewController;
        [controller configureWithTourId:self.tour.sid andLocation:self.mapView.region.center];
        controller.encounters = self.encounters;
    }
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)zoomToCurrentLocation:(id)sender {
	float spanX = 0.0001;
	float spanY = 0.0001;
	MKCoordinateRegion region;

	region.center.latitude = self.mapView.userLocation.coordinate.latitude;
	region.center.longitude = self.mapView.userLocation.coordinate.longitude;

	region.span.latitudeDelta = spanX;
	region.span.longitudeDelta = spanY;
	[self.mapView setRegion:region animated:YES];
}

- (IBAction)launcherTour:(id)sender {
    self.launcherButton.hidden = YES;
    self.launcherView.hidden = NO;
}

- (IBAction)feetButtonDidTap:(id)sender {
    [self.feetButton setSelected:YES];
    [self.carButton setSelected:NO];
}

- (IBAction)carButtonDidTap:(id)sender {
    [self.carButton setSelected:YES];
    [self.feetButton setSelected:NO];
}

- (IBAction)typeButtonDidTap:(UIView *)sender {
    for (UIButton *button in self.typeButtons) {
        button.selected = (button == sender);
    }
}

- (IBAction)startTour:(id)sender {
    self.tour = [[OTTour alloc] initWithTourType:[self selectedTourType] andVehicleType:[self selectedVehiculeType]];
    [self sendTour];
    
    self.launcherView.hidden = YES;
    self.stopButton.hidden = NO;
    self.createEncounterButton.hidden = NO;
    
    self.seconds = 0;
    self.distance = 0;
    self.locations = [NSMutableArray new];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(eachSecond) userInfo:nil repeats:YES];
    self.isTourRunning = YES;
}

- (IBAction)stopTour:(id)sender {
    self.tour.status = NSLocalizedString(@"tour_status_closed", @"");
    [self closeTour];
    self.tour = nil;
    [self.pointsToSend removeAllObjects];
    [self.encounters removeAllObjects];
    
    
    self.launcherView.hidden = YES;
    self.launcherButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.createEncounterButton.hidden = YES;
    self.isTourRunning = NO;
}

/**************************************************************************************************/
#pragma mark - Utils

- (NSString *)selectedVehiculeType {
    if (self.feetButton.selected) {
        return NSLocalizedString(@"tour_vehicle_feet", @"");
    }
    else if (self.carButton.selected) {
        return NSLocalizedString(@"tour_vehicle_car", @"");
    }
    return nil;
}

- (NSString *)selectedTourType {
    NSInteger selectedType = 0;
    for (UIButton *button in self.typeButtons) {
        if (button.selected) {
            selectedType = button.tag;
        }
    }
    switch (selectedType) {
        case OTTypesSocial:
            return NSLocalizedString(@"tour_type_social", @"");
            break;
        case OTTypesOther:
            return NSLocalizedString(@"tour_type_other", @"");
            break;
        case OTTypesFood:
            return NSLocalizedString(@"tour_type_food", @"");
            break;
    }
    return nil;
}

@end
