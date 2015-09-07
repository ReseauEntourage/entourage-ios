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
#import "OTMeetingCalloutViewController.h"
#import "OTCreateMeetingViewController.h"

// View
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "JSBadgeView.h"

// Model
#import "OTPoi.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTEncounter.h"

// Service
#import "OTPoiService.h"
#import "OTTourService.h"

// Framework
#import <MapKit/MKMapView.h>
#import <WYPopoverController/WYPopoverController.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "KPClusteringController.h"
#import "KPAnnotation.h"

#import "NSUserDefaults+OT.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMapViewController () <MKMapViewDelegate, OTCalloutViewControllerDelegate, OTMeetingCalloutViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

// map

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// markers

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, strong) NSArray *encounters;

@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic, strong) KPClusteringController *clusteringController;

@property (nonatomic) BOOL isRegionSetted;
@property (nonatomic, strong) NSArray *tableData;

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
@property (weak, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
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
//	[self refreshMap];
    
    self.launcherView.hidden = YES;
    if (self.isTourRunning) {
        self.launcherButton.hidden = YES;
        self.createEncounterButton.hidden = NO;
        self.stopButton.hidden = NO;
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
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"currentUser"];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)configureView {
	self.title = NSLocalizedString(@"mapviewcontroller_title", @"");
	self.tableData = [self filterCurrentAnnotations:[self.mapView annotationsInMapRect:self.mapView.visibleMapRect]];

	if (self.mapButton.isSelected) {
		[self configureMapView];
	}
	else if (self.listButton.isSelected) {
		[self configureListView];
	}
}

- (void)configureMapView {
	[self.tableView setHidden:YES];
}

- (void)configureListView {
	[self.tableView setHidden:NO];
}

- (void)registerObserver {
	[[NSUserDefaults standardUserDefaults] addObserver:self
	                                        forKeyPath:@"currentUser"
	                                           options:NSKeyValueObservingOptionNew
	                                           context:nil];
}

- (void)refreshMap {
	[[OTPoiService new] poisAroundCoordinate:self.mapView.centerCoordinate
	                                distance:[self mapHeight]
	                                 success: ^(NSArray *categories, NSArray *pois, NSArray *encounters)
	{
	    [self.indicatorView setHidden:YES];

	    self.categories = categories;
	    self.pois = pois;
	    self.encounters = encounters;

	    [self feedMapViewWithPoiArray:pois];
	    [self feedMapViewWithEncountersArray:encounters];
	    [self insertCurrentAnnotationsInTableView:[self filterCurrentAnnotations:[self.mapView annotationsInMapRect:self.mapView.visibleMapRect]]];
	}

	                                 failure: ^(NSError *error)
	{
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

- (void)feedMapViewWithPoiArray:(NSArray *)array {
	for (OTPoi *poi in array) {
		OTCustomAnnotation *pointAnnotation = [[OTCustomAnnotation alloc] initWithPoi:poi];
		[self.mapView addAnnotation:pointAnnotation];
	}
}

- (void)feedMapViewWithEncountersArray:(NSArray *)array {
	NSMutableArray *annotations = [NSMutableArray new];

	for (OTEncounter *encounter in array) {
		OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
		[annotations addObject:pointAnnotation];
	}
	[self.clusteringController setAnnotations:annotations];
}

- (NSArray *)filterCurrentAnnotations:(NSSet *)annots {
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

- (void)insertCurrentAnnotationsInTableView:(NSArray *)annotationsToAdd {
	NSArray *indexPaths = [[NSArray alloc] init];
	NSInteger nbAnnotationsToAdd = [annotationsToAdd count];

	self.tableData = annotationsToAdd;

	for (int i = 0; i < nbAnnotationsToAdd; i++) {
		[indexPaths arrayByAddingObject:[NSIndexPath indexPathForRow:i inSection:0]];
	}

	[self.tableView reloadData];
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
        NSLog(@"%@", @"open success");
    } failure:^(NSError *error) {
        NSLog(@"%@", @"open failure");
    }];
}

- (void)closeTour {
    [[OTTourService new] closeTour:self.tour withSuccess:^(OTTour *closedTour) {
        NSLog(@"%@", @"close success");
    } failure:^(NSError *error) {
        NSLog(@"%@", @"close failure");
    }];
}

- (void)sendTourPoints:(NSMutableArray *)tourPoint {
    [[OTTourService new] sendTourPoint:tourPoint withTourId:self.tour.sid withSuccess:^(OTTour *updatedTour) {
        NSLog(@"%@", @"update points success");
    } failure:^(NSError *error) {
        NSLog(@"%@", @"update points failure");
    }];
}

/********************************************************************************/
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
	MKAnnotationView *annotationView = nil;

	if ([annotation isKindOfClass:[OTCustomAnnotation class]]) {
		OTCustomAnnotation *customAnnotation = (OTCustomAnnotation *)annotation;
		annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:customAnnotation.annotationIdentifier];

		if (!annotationView) {
			annotationView = customAnnotation.annotationView;
		}
		annotationView.annotation = annotation;
	}
	else if ([annotation isKindOfClass:[KPAnnotation class]]) {
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

	if ([view.annotation isKindOfClass:[OTCustomAnnotation class]]) {
		// Start up our view controller from a Storyboard
		OTCalloutViewController *controller = (OTCalloutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OTCalloutViewController"];
		controller.delegate = self;

		UIView *popView = [controller view];

		popView.frame = CGRectOffset(view.frame, .0f, CGRectGetHeight(popView.frame) + 10000.f);

		[UIView animateWithDuration:.3f
		                 animations: ^
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
		[Flurry logEvent:@"Open_POI_From_Map" withParameters:@{ @"poi_id" : annotation.poi.sid }];
	}
	else if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
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
                    [self.pointsToSend addObject:[[OTTourPoint alloc] initWithLocation:newLocation]];
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

/********************************************************************************/
#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover {
	[self.popover dismissPopoverAnimated:YES];
}

/********************************************************************************/
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *simpleTableIdentifier = @"EncounterItem";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
	}

	cell.textLabel.text = [self encounterAnnotationToString:self.tableData[(NSUInteger)indexPath.row]];
	return cell;
}

/********************************************************************************/
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	OTEncounterAnnotation *annotationToDisplay = [self.tableData objectAtIndex:[indexPath row]];
	[self displayEncounter:annotationToDisplay];
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)mapButtonDidTap:(id)sender {
	[self.mapButton setSelected:YES];
	[self.listButton setSelected:NO];
	[self configureView];
}

- (IBAction)listButtonDidTap:(id)sender {
	[self.mapButton setSelected:NO];
	[self.listButton setSelected:YES];
	[self configureView];
}

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

- (IBAction)createEncounter:(id)sender {
	OTCreateMeetingViewController *controller = (OTCreateMeetingViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OTCreateMeetingViewController"];
	[controller configureWithLocation:self.mapView.region.center];
	[self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)launcherTour:(id)sender {
    self.launcherButton.hidden = YES;
    self.launcherView.hidden = NO;
}

- (IBAction)startTour:(id)sender {
    self.tour = [OTTour new];
    self.pointsToSend = [NSMutableArray new];
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
    self.tour.status = @"closed";
    [self closeTour];
    self.pointsToSend = nil;
    
    self.launcherView.hidden = YES;
    self.launcherButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.createEncounterButton.hidden = YES;
    self.isTourRunning = NO;
}

@end
