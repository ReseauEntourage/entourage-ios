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
#import "OTCreateMeetingViewController.h"
#import "OTToursTableViewController.h"
#import "OTCalloutViewController.h"

// View
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "JSBadgeView.h"
#import "SVProgressHUD.h"

// Model
#import "OTUser.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTEncounter.h"

// Service
#import "OTTourService.h"

// Framework
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKMapView.h>
#import <CoreLocation/CoreLocation.h>
#import <WYPopoverController/WYPopoverController.h>
#import <QuartzCore/QuartzCore.h>
#import "KPClusteringController.h"
#import "KPAnnotation.h"

// User
#import "NSUserDefaults+OT.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

// map

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) NSMapTable *drawnTours;
@property (weak, nonatomic) IBOutlet UIImageView *pointerPin;

// markers

@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic) BOOL isRegionSetted;
@property (nonatomic, strong) KPClusteringController *clusteringController;

// tour

@property BOOL isTourRunning;
@property int seconds;
@property NSString *currentTourType;
@property (nonatomic, strong) OTTour *tour;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *pointsToSend;
@property (nonatomic, strong) NSMutableArray *closeTours;
@property (nonatomic, strong) NSDate *start;

// tour lifecycle

@property (nonatomic, weak) IBOutlet UIView *launcherView;
@property (nonatomic, weak) IBOutlet UIButton *launcherButton;
@property (nonatomic, weak) IBOutlet UIButton *launcherCloseButton;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *createEncounterButton;

// launcher

@property (nonatomic, weak) IBOutlet UIButton *feetButton;
@property (nonatomic, weak) IBOutlet UIButton *carButton;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *typeButtons;

// tours

@property (nonatomic, strong) NSMutableArray *tours;

// Push test
@property (weak, nonatomic) IBOutlet UIButton *notifButton;


@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.pointsToSend = [NSMutableArray new];
    self.encounters = [NSMutableArray new];
    //self.closeTours = [NSMutableArray new];
    self.drawnTours = [NSMapTable new];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
	_locationManager = [[CLLocationManager alloc] init];
	if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[self.locationManager requestWhenInUseAuthorization];
	}
	[self.locationManager startUpdatingLocation];

	self.mapView.showsUserLocation = YES;
	self.mapView.delegate = self;
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
    [self.mapView addGestureRecognizer:self.tapGestureRecognizer];
	[self zoomToCurrentLocation:nil];
	[self createMenuButton];
	[self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    [self clearMap];
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
    //[self.timer invalidate];
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
                                      distance:[NSNumber numberWithDouble:[self mapHeight]]
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
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"user_tours_only"]) {
        [[OTTourService new] toursByUserId:[[NSUserDefaults standardUserDefaults] currentUser].sid
                            withPageNumber:@1
                          andNumberPerPage:@50
                                   success:^(NSMutableArray *userTours) {
                                       [self.indicatorView setHidden:YES];
                                       self.tours = userTours;
                                       [self feedMapViewWithTours];
                                   } failure:^(NSError *error) {
                                       [self registerObserver];
                                       [self.indicatorView setHidden:YES];
                                   }];
    }
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
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:[tour.tourPoints count]];
    //OTTour *t = [self.drawnTours objectForKey:polyline];
    //if (t == nil) {
        [self.drawnTours setObject:tour forKey:polyline];
        [self.mapView addOverlay:polyline];
    //}
}

- (NSString *)encounterAnnotationToString:(OTEncounterAnnotation *)annotation {
	OTEncounter *encounter = [annotation encounter];
	NSString *cellTitle = [NSString stringWithFormat:@"%@ a rencontré %@",
	                       encounter.userName,
	                       encounter.streetPersonName];

	return cellTitle;
}

- (void)displayEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view {
	OTMeetingCalloutViewController *controller = (OTMeetingCalloutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OTMeetingCalloutViewController"];
	controller.delegate = self;
 
    OTEncounterAnnotation *encounterAnnotation = (OTEncounterAnnotation *)simpleAnnontation;
    OTEncounter *encounter = encounterAnnotation.encounter;
    [self presentViewController:controller animated:YES completion:nil];
    [controller configureWithEncouter:encounter];
    
    /*
    UIView *popView = [controller view];
    popView.frame = CGRectOffset(view.frame, .0f, CGRectGetHeight(popView.frame) + 10000.f);
    [UIView animateWithDuration:.3f animations: ^{
         popView.frame = CGRectOffset(popView.frame, .0f, -CGRectGetHeight(popView.frame));
     }];
    
    self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
    [self.popover setTheme:[WYPopoverTheme themeForIOS7]];
    
    [self.popover presentPopoverFromRect:view.bounds
                                  inView:view
                permittedArrowDirections:WYPopoverArrowDirectionNone
                                animated:YES
                                 options:WYPopoverAnimationOptionFadeWithScale];
     */

	//[Flurry logEvent:@"Open_Encounter_From_Map" withParameters:@{ @"encounter_id" : encounterAnnotation.encounter.sid }];
}

- (void)eachSecond {
    self.seconds++;
}

- (void)sendTour {
    [[OTTourService new] sendTour:self.tour withSuccess:^(OTTour *sentTour) {
        self.tour.sid = sentTour.sid;
        self.tour.distance = 0.0;
        
        self.pointerPin.hidden = NO;
        self.launcherView.hidden = YES;
        self.stopButton.hidden = NO;
        self.createEncounterButton.hidden = NO;
        
        self.seconds = 0;
        self.locations = [NSMutableArray new];
        self.isTourRunning = YES;
        self.start = [NSDate date];
    } failure:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

- (void)sendTourPoints:(NSMutableArray *)tourPoint {
    [[OTTourService new] sendTourPoint:tourPoint withTourId:self.tour.sid withSuccess:^(OTTour *updatedTour) {
    } failure:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
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
	[self refreshMap];
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
                [self displayEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            if (self.locations.count > 0) {
            
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
        
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [self.mapView setRegion:region animated:YES];
            
                if (self.isTourRunning) {
                    self.tour.distance += [newLocation distanceFromLocation:self.locations.lastObject];
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
        
        OTTour *tour = [self.drawnTours objectForKey:polyline];
        if ([tour.tourType isEqualToString:@"medical"]) {
            aRenderer.strokeColor = [UIColor redColor];
        }
        else if ([tour.tourType isEqualToString:@"barehands"]) {
            aRenderer.strokeColor = [UIColor blueColor];
        }
        else if ([tour.tourType isEqualToString:@"alimentary"]) {
            aRenderer.strokeColor = [UIColor greenColor];
        }
        
        if (self.isTourRunning && tour == nil) {
            if ([self.currentTourType isEqualToString:@"medical"]) {
                aRenderer.strokeColor = [UIColor redColor];
            }
            else if ([self.currentTourType isEqualToString:@"barehands"]) {
                aRenderer.strokeColor = [UIColor blueColor];
            }
            else if ([self.currentTourType isEqualToString:@"alimentary"]) {
                aRenderer.strokeColor = [UIColor greenColor];
            }
        }
        
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}

- (void)clearMap {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:[self.mapView overlays]];
}

/********************************************************************************/
#pragma mark - UIGestureRecognizerDelegate

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self.mapView];
        CLLocationCoordinate2D location = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        [[OTTourService new] toursAroundCoordinate:location
                                             limit:@5
                                          distance:@0.04
                                           success:^(NSMutableArray *closeTours) {
                                               [self.indicatorView setHidden:YES];
                                               if (closeTours.count != 0) {
                                                   self.closeTours = closeTours;
                                                   [self performSegueWithIdentifier:@"OTCloseTours" sender:sender];
                                               }
                                           } failure:^(NSError *error) {
                                               [self registerObserver];
                                               [self.indicatorView setHidden:YES];
                                           }];
    }
}

/********************************************************************************/
#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover {
	[self.popover dismissPopoverAnimated:YES];
}

/********************************************************************************/
#pragma mark - OTConfirmationViewControllerDelegate

- (void)tourSent {
    [SVProgressHUD showSuccessWithStatus:@"Maraude terminée !"];
    
    self.tour = nil;
    self.currentTourType = nil;
    [self.pointsToSend removeAllObjects];
    [self.encounters removeAllObjects];
    
    self.pointerPin.hidden = YES;
    self.launcherView.hidden = YES;
    self.launcherButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.createEncounterButton.hidden = YES;
    self.isTourRunning = NO;
    [self clearMap];
}

- (void)resumeTour {
    self.isTourRunning = YES;
}

/********************************************************************************/
#pragma mark - OTCreateMeetingViewControllerDelegate

- (void)encounterSent:(OTEncounter *)encounter {
    [self feedMapViewWithEncounters];
}

/********************************************************************************/
#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OTCreateMeeting"]) {
        OTCreateMeetingViewController *controller = (OTCreateMeetingViewController *)segue.destinationViewController;
        controller.delegate = self;
        [controller configureWithTourId:self.tour.sid andLocation:self.mapView.region.center];
        controller.encounters = self.encounters;
    } else if ([segue.identifier isEqualToString:@"OTConfirmationPopup"]) {
        OTConfirmationViewController *controller = (OTConfirmationViewController *)segue.destinationViewController;
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.delegate = self;
        self.isTourRunning = NO;
        [controller configureWithTour:self.tour
                   andEncountersCount:[NSNumber numberWithUnsignedInteger:[self.encounters count]]
                          andDuration:[[NSDate date] timeIntervalSinceDate:self.start]];
    } else if ([segue.identifier isEqualToString:@"OTCloseTours"]) {
        OTToursTableViewController *controller = (OTToursTableViewController *)segue.destinationViewController;
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [controller setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [controller configureWithTours:self.closeTours];
    }
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)zoomToCurrentLocation:(id)sender {
	float spanX = 0.01;
	float spanY = 0.01;
	MKCoordinateRegion region;

	region.center.latitude = self.mapView.userLocation.coordinate.latitude;
	region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    
    if (region.center.latitude < .00001 && region.center.longitude < .00001) {
        region.center = CLLocationCoordinate2DMake(48.856578, 2.351828);
    }

	region.span.latitudeDelta = spanX;
	region.span.longitudeDelta = spanY;
	[self.mapView setRegion:region animated:YES];
}

- (IBAction)launcherTour:(id)sender {
    self.launcherButton.hidden = YES;
    self.launcherView.hidden = NO;
}

- (IBAction)closeLauncher:(id)sender {
    self.launcherButton.hidden = NO;
    self.launcherView.hidden = YES;
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
}

- (IBAction)stopTour:(id)sender {
    [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:sender];
}

- (IBAction)sendNotification:(id)sender {
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.userInfo = @{ @"sender" : @"Developers", @"object" : @"Besoin de vêtements", @"content" : @"Un SDF a besoin de vêtements au 5 rue du temple."};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
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
        case OTTypesBareHands:
            self.currentTourType = NSLocalizedString(@"tour_type_bare_hands", @"");
            break;
        case OTTypesMedical:
            self.currentTourType = NSLocalizedString(@"tour_type_medical", @"");
            break;
        case OTTypesAlimentary:
            self.currentTourType = NSLocalizedString(@"tour_type_alimentary", @"");
            break;
    }
    return self.currentTourType;
}

@end
