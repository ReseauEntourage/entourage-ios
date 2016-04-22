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
#import "OTMapOptionsViewController.h"
#import "OTTourOptionsViewController.h"
#import "OTTourJoinRequestViewController.h"
#import "OTTourViewController.h"
#import "OTPublicTourViewController.h"
#import "OTQuitTourViewController.h"
#import "OTGuideViewController.h"
#import "UIView+entourage.h"
#import "OTUserViewController.h"
#import "OTGuideDetailsViewController.h"

#import "OTNewsfeedMapDelegate.h"
#import "OTGuideMapDelegate.h"

#import "KPAnnotation.h"
#import "KPClusteringController.h"
#import "JSBadgeView.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"

#import "OTConsts.h"

// View
#import "SVProgressHUD.h"
#import "OTToursTableView.h"

// Model
#import "OTUser.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTEncounter.h"
#import "OTPOI.h"

// Service
#import "OTTourService.h"
#import "OTAuthService.h"
#import "OTPOIService.h"

#import "UIButton+entourage.h"
#import "UIColor+entourage.h"
#import "UILabel+entourage.h"

// Framework
#import <UIKit/UIKit.h>
#import <WYPopoverController/WYPopoverController.h>
#import <QuartzCore/QuartzCore.h>
#import "TTTTimeIntervalFormatter.h"
#import "TTTLocationFormatter.h"

// User
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"



#define PARIS_LAT 48.856578
#define PARIS_LON  2.351828
#define MAPVIEW_HEIGHT 160.f
#define MAPVIEW_REGION_SPAN_X_METERS 500
#define MAPVIEW_REGION_SPAN_Y_METERS 500
#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define TOURS_REQUEST_DISTANCE_KM 10
#define LOCATION_MIN_DISTANCE 5.f

#define TABLEVIEW_FOOTER_HEIGHT 15.0f
#define TABLEVIEW_BOTTOM_INSET 86.0f



/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMapViewController () <CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, OTTourOptionsDelegate, OTTourJoinRequestDelegate, OTMapOptionsDelegate, OTToursTableViewDelegate>

// map

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapSegmentedControl;
@property (nonatomic, weak) IBOutlet OTToursTableView *tableView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak) IBOutlet UIImageView *pointerPin;

@property (nonatomic, strong) OTNewsfeedMapDelegate *newsfeedMapDelegate;
@property (nonatomic, strong) OTGuideMapDelegate *guideMapDelegate;

// markers

@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic) BOOL isRegionSetted;

// tour

@property (nonatomic, assign) CGPoint mapPoint;
@property int seconds;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *pointsToSend;
@property (nonatomic, strong) NSMutableArray *closeTours;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic) BOOL isTourListDisplayed;

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
@property (nonatomic, strong) OTToursTableView *toursTableView;
@property (nonatomic) CLLocationCoordinate2D requestedToursCoordinate;

// POI

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, strong) NSMutableArray *markers;

@end

@implementation OTMapViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
    [self configureNavigationBar];
    
    self.locations = [NSMutableArray new];
    self.pointsToSend = [NSMutableArray new];
    self.encounters = [NSMutableArray new];
    self.markers = [NSMutableArray new];
    
    self.newsfeedMapDelegate = [[OTNewsfeedMapDelegate alloc] initWithMapController:self];
    self.guideMapDelegate = [[OTGuideMapDelegate alloc] initWithMapController:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTourConfirmation) name:@kNotificationLocalTourConfirmation object:nil];

	[self configureTableView];
    
    [self switchToNewsfeed];
    if (self.isTourRunning) {
        [self showNewTourOnGoing];
    } else {
        [self showToursMap];
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
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
        self.launcherButton.hidden = NO;
        self.stopButton.hidden = YES;
        self.createEncounterButton.hidden = YES;
    }
    [self startLocationUpdates];

    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
   }

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.timer invalidate];
    if (_isTourRunning)
        [self createLocalNotificationForTour:self.tour.sid];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self refreshMap];
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")];
}

- (void)switchToNewsfeed {
    self.newsfeedMapDelegate.isActive = YES;
    self.guideMapDelegate.isActive = NO;
    self.mapView.delegate = self.newsfeedMapDelegate;
    self.mapSegmentedControl.hidden = NO;
    //[self clearMap];
    [self.newsfeedMapDelegate mapView:self.mapView regionDidChangeAnimated:YES];
    if (self.isTourListDisplayed) {
        [self showToursList];
    }
}

- (void)switchToGuide {
    self.newsfeedMapDelegate.isActive = NO;
    self.guideMapDelegate.isActive = YES;
    self.mapView.delegate = self.guideMapDelegate;
    [self clearMap];
    [self showToursMap];
    [self.guideMapDelegate mapView:self.mapView regionDidChangeAnimated:YES];
}

/**************************************************************************************************/
#pragma mark - Private methods
- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    return [formatter stringFromDate:date];
}

- (void)configureTableView {
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, -TABLEVIEW_FOOTER_HEIGHT, 0.0f);
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, TABLEVIEW_BOTTOM_INSET)];
    self.tableView.tableFooterView = dummyView;
    
    //show map on table header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width+8, MAPVIEW_HEIGHT)];
    self.mapView = [[MKMapView alloc] initWithFrame:headerView.bounds];
    [headerView addSubview:self.mapView];
    [headerView sendSubviewToBack:self.mapView];
    [self configureMapView];
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 156.0f , headerView.frame.size.width + 130.0f, 4.0f)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = shadowView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)([UIColor colorWithRed:0 green:0 blue:0 alpha:.2].CGColor),  nil];
    [shadowView.layer insertSublayer:gradient atIndex:1];
    [headerView addSubview:shadowView];
    
    NSDictionary *viewsDictionary = @{@"shadow":shadowView};
    NSArray *constraint_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[shadow(4)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];
    NSArray *constraint_pos_horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-8)-[shadow]-(-8)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    NSArray *constraint_pos_bottom = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[shadow]-0-|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:viewsDictionary];
    shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    [shadowView addConstraints:constraint_height];
    [headerView addConstraints:constraint_pos_horizontal];
    [headerView addConstraints:constraint_pos_bottom];
    self.mapView.center = headerView.center;
    self.tableView.tableHeaderView = headerView;
    self.tableView.toursDelegate = self;
}

- (void)configureMapView {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance( CLLocationCoordinate2DMake(PARIS_LAT, PARIS_LON), MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
    
    [self.mapView setRegion:region animated:YES];
    
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];

    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:self.tapGestureRecognizer];

   	self.mapView.showsUserLocation = YES;
    //self.mapView.delegate = self;
    [self zoomToCurrentLocation:nil];
    
    UIGestureRecognizer *longPressMapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMapOverlay:)];
    [self.mapView addGestureRecognizer:longPressMapGesture];
}

- (void)configureNavigationBar {
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    
    [self createMenuButton];
    UIBarButtonItem *chatButton = [self setupChatsButton];
    [chatButton setTarget:self];
    [chatButton setAction:@selector(showEntourages)];
    [self setupLogoImage];
}

- (void)showMapOverlay:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint touchPoint = [longPressGesture locationInView:self.mapView];

    if (_isTourRunning) {
        self.mapPoint = touchPoint;
        [self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
    } else {
        [self showMapOverlayToCreateTourAtPoint:touchPoint];
    }
}

- (void)appWillEnterBackground:(NSNotification*)note {
    if (self.isTourRunning) {
        [self createLocalNotificationForTour:self.tour.sid];
    } else {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)appWillEnterForeground:(NSNotification*)note {
    [self.locationManager startUpdatingLocation];
}

- (void)showEntourages {
    [self performSegueWithIdentifier:@"EntouragesSegue" sender:self];
}

- (void)registerObserver {
	[[NSUserDefaults standardUserDefaults] addObserver:self
	                                        forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")
	                                           options:NSKeyValueObservingOptionNew
	                                           context:nil];
}


static BOOL didGetAnyData = NO;
- (void)refreshMap {
    if (self.newsfeedMapDelegate.isActive) {
        [self getTourList];
    }
    else {
        [self getPOIList];
    }
}

- (void)getTourList {
    // check if we need to make a new request
    CLLocationDistance distance = (MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.requestedToursCoordinate), MKMapPointForCoordinate(self.mapView.centerCoordinate))) / 1000.0f;
    if (distance < TOURS_REQUEST_DISTANCE_KM / 4) {
        return;
    }
    __block CLLocationCoordinate2D oldRequestedCoordinate;
    oldRequestedCoordinate.latitude = self.requestedToursCoordinate.latitude;
    oldRequestedCoordinate.longitude = self.requestedToursCoordinate.longitude;
    self.requestedToursCoordinate = self.mapView.centerCoordinate;
    
    [[OTTourService new] toursAroundCoordinate:self.mapView.centerCoordinate
                                         limit:@20
                                      distance:@TOURS_REQUEST_DISTANCE_KM //*[NSNumber numberWithDouble:[self mapHeight]]
                                       success:^(NSMutableArray *closeTours)
     {
         if (closeTours.count && !didGetAnyData) {
             [self showToursList];
             didGetAnyData = YES;
         }
         [self.indicatorView setHidden:YES];
         self.tours = closeTours;
         [self.tableView removeAll];
         [self.tableView addTours:closeTours];
         [self feedMapViewWithTours];
         [self.tableView reloadData];
     }
                                       failure:^(NSError *error) {
                                           self.requestedToursCoordinate = oldRequestedCoordinate;
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
                                       [self.tableView addTours:userTours];
                                       [self feedMapViewWithTours];
                                       [self.tableView reloadData];
                                   } failure:^(NSError *error) {
                                       [self registerObserver];
                                       [self.indicatorView setHidden:YES];
                                   }];
    }
}

- (void)getPOIList {
    [[OTPoiService new] poisAroundCoordinate:self.mapView.centerCoordinate
                                    distance:[self mapHeight]
                                     success:^(NSArray *categories, NSArray *pois)
     {
         [self.indicatorView setHidden:YES];
         
         self.categories = categories;
         self.pois = pois;
         
         [self feedMapViewWithPoiArray:pois];
     }
                                     failure:^(NSError *error) {
                                         [self registerObserver];
                                         [self.indicatorView setHidden:YES];
                                     }];
}

- (void)feedMapViewWithEncounters {
    if (self.newsfeedMapDelegate.isActive) {
        NSMutableArray *annotations = [NSMutableArray new];

        for (OTEncounter *encounter in self.encounters) {
            OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
            [annotations addObject:pointAnnotation];
        }
        
        [self.clusteringController setAnnotations:annotations];
    }
}

- (void)feedMapViewWithTours {
    self.newsfeedMapDelegate.drawnTours = [[NSMapTable alloc] init];
    if (self.newsfeedMapDelegate.isActive) {
        for (OTTour *tour in self.tours) {
            [self drawTour:tour];
        }
    }
}

- (void)feedMapViewWithPoiArray:(NSArray *)array {
    if (self.guideMapDelegate.isActive) {
        for (OTPoi *poi in array) {
            OTCustomAnnotation *annotation = [[OTCustomAnnotation alloc] initWithPoi:poi];
            if (![self.markers containsObject:annotation]) {
                [self.markers addObject:annotation];
            }
        }
        [self.clusteringController setAnnotations:self.markers];
    }
}

- (void)drawTour:(OTTour *)tour {
    NSLog(@"drawing %@ tour %d with %lu points ...", tour.vehicleType, tour.sid.intValue, (unsigned long)tour.tourPoints.count);
    CLLocationCoordinate2D coords[[tour.tourPoints count]];
    int count = 0;
    for (OTTourPoint *point in tour.tourPoints) {
        coords[count++] = point.toLocation.coordinate;
    }
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:[tour.tourPoints count]];
    [self.newsfeedMapDelegate.drawnTours setObject:tour forKey:polyline];
    [self.mapView addOverlay:polyline];
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
    [controller setEncounter:encounter];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
    
//    [controller configureWithEncouter:encounter];
	//[Flurry logEvent:@"Open_Encounter_From_Map" withParameters:@{ @"encounter_id" : encounterAnnotation.encounter.sid }];
}

- (void)displayPoiDetails:(MKAnnotationView *)view {
    KPAnnotation *kpAnnotation = view.annotation;
    __block OTCustomAnnotation *annotation = nil;
    [[kpAnnotation annotations] enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[OTCustomAnnotation class]]) {
            annotation = obj;
            *stop = YES;
        }
    }];
    
    if (annotation == nil) return;
    
    [Flurry logEvent:@"Open_POI_From_Map" withParameters:@{ @"poi_id" : annotation.poi.sid }];
    
    [self performSegueWithIdentifier:@"OTGuideDetailsSegue" sender:annotation];
}

- (CLLocationDistance)mapHeight {
    MKMapPoint mpTopRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
                                           self.mapView.visibleMapRect.origin.y);
    
    MKMapPoint mpBottomRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
                                              self.mapView.visibleMapRect.origin.y + self.mapView.visibleMapRect.size.height);
    
    CLLocationDistance vDist = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight) / 1000.f;
    
    return vDist;
}

- (void)eachSecond {
    self.seconds++;
}

- (void)sendTour {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"tour_create_sending", @"")];
    [[OTTourService new]
         sendTour:self.tour
         withSuccess:^(OTTour *sentTour) {
             [SVProgressHUD dismiss];
             self.tour.sid = sentTour.sid;
             self.tour.distance = 0.0;
             
             self.pointerPin.hidden = NO;
             self.launcherView.hidden = YES;
             self.stopButton.hidden = NO;
             self.createEncounterButton.hidden = NO;
             
             [self showNewTourOnGoing];
             
             self.seconds = 0;
             self.locations = [NSMutableArray new];
             self.isTourRunning = YES;
             
             if ([self.pointsToSend count] > 0) {
                 [self performSelector:@selector(sendTourPoints:) withObject:self.pointsToSend afterDelay:0.0];
             }
             
             //[self createLocalNotificationForTour:self.tour.sid];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"tour_create_error", @"")];
            NSLog(@"%@",[error localizedDescription]);
        }
     ];
}

- (void)createLocalNotificationForTour:(NSNumber*)tourId {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    localNotification.alertBody = @"Maraude en cours";
    localNotification.alertAction = @"Stop";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = @{@"tourId": tourId, @"object":@"Maraude en cours"};
    localNotification.applicationIconBadgeNumber = 0;//[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}


- (void)sendTourPoints:(NSMutableArray *)tourPoint {
    __block NSArray *sentPoints = [NSArray arrayWithArray:tourPoint];
    [[OTTourService new] sendTourPoint:tourPoint
                            withTourId:self.tour.sid
                           withSuccess:^(OTTour *updatedTour) {
                               [self.pointsToSend removeObjectsInArray:sentPoints];
                           }
                               failure:^(NSError *error) {
                                   NSLog(@"%@",[error localizedDescription]);
                               }
     ];
}

- (void)addTourPointFromLocation:(CLLocation *)location {
    self.tour.distance += [location distanceFromLocation:self.locations.lastObject];
    OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:location];
    [self.tour.tourPoints addObject:tourPoint];
    [self.pointsToSend addObject:tourPoint];
    [self sendTourPoints:self.pointsToSend];
}


- (OTPoiCategory*)categoryById:(NSNumber*)sid {
    if (sid == nil) return nil;
    for (OTPoiCategory* category in self.categories) {
        if (category.sid != nil) {
            if ([category.sid isEqualToNumber:sid]) {
                return category;
            }
        }
    }
    return nil;
}

/********************************************************************************/
#pragma mark - Location Manager

- (void)startLocationUpdates {
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    self.locationManager.distanceFilter = 5; // meters
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *newLocation in locations) {
        //NSLog(@"LOC %.4f, %.4f of %lu", newLocation.coordinate.latitude, newLocation.coordinate.longitude, (unsigned long)locations.count);
        
        //Negative accuracy means invalid coordinates
        if (newLocation.horizontalAccuracy < 0) {
            continue;
        }
        
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        double distance = 1000.0f;
        if ([self.locations count] > 0) {
            CLLocation *previousLocation = self.locations.lastObject;
            distance = [newLocation distanceFromLocation:previousLocation];
        }
        
        //NSLog(@"distance = %.0f howRecent = %.2f accuracy = %.2f", distance, fabs(howRecent), newLocation.horizontalAccuracy);
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20 && fabs(distance) > LOCATION_MIN_DISTANCE) {
            
            if (self.locations.count > 0) {
            
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                
                MKCoordinateRegion region = self.mapView.region;
                region.center = newLocation.coordinate;
                [self.mapView setRegion:region animated:YES];
            
                if (self.isTourRunning) {
                    [self addTourPointFromLocation:newLocation];
                    if (self.newsfeedMapDelegate.isActive) {
                        [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
                    }
                }
            }
        
            [self.locations addObject:newLocation];
        }
    }
}

- (void)clearMap {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:[self.mapView overlays]];
}

/********************************************************************************/
#pragma mark - UIGestureRecognizerDelegate

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self showToursMap];
//        
//        CGPoint point = [sender locationInView:self.mapView];
//        CLLocationCoordinate2D location = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
//        [[OTTourService new] toursAroundCoordinate:location
//                                             limit:@5
//                                          distance:@0.04
//                                           success:^(NSMutableArray *closeTours) {
//                                               [self.indicatorView setHidden:YES];
//                                               if (closeTours.count != 0) {
//                                                   self.closeTours = closeTours;
//                                                   [self performSegueWithIdentifier:@"OTCloseTours" sender:sender];
//                                               }
//                                           } failure:^(NSError *error) {
//                                               [self registerObserver];
//                                               [self.indicatorView setHidden:YES];
//                                           }];
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
    [SVProgressHUD showSuccessWithStatus:@"Maraude terminée!"];
    
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
    self.requestedToursCoordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
    [self clearMap];
    //[self showToursList];
    [self refreshMap];
}

- (void)resumeTour {
    self.isTourRunning = YES;
    self.stopButton.hidden = NO;
    self.createEncounterButton.hidden = NO;
}

/********************************************************************************/
#pragma mark - OTCreateMeetingViewControllerDelegate

- (void)encounterSent:(OTEncounter *)encounter {
    [self dismissViewControllerAnimated:YES completion:^{
        [self feedMapViewWithEncounters];
    }];
}

/********************************************************************************/
#pragma mark - OTTourOptionsDelegate

- (void)createEncounter {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.newsfeedMapDelegate.isActive) {
            [self performSegueWithIdentifier:@"OTCreateMeeting" sender:nil];
        } else {
            [self showNewEncounterStartDialogFromGuide];
        }
    }];
}

- (void)dismissTourOptions {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.isTourRunning) {
            [self showNewTourOnGoing];
        }
    }];
}

/********************************************************************************/
#pragma mark - OTMapOptionsDelegate

- (void)createTour {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.newsfeedMapDelegate.isActive) {
            [self showNewTourStart];
        } else {
            [self showNewTourStartDialogFromGuide];
        }
    }];
}

- (void)togglePOI {
    [self dismissViewControllerAnimated:NO completion:^{
        //[self performSegueWithIdentifier:@"GuideSegue" sender:nil];
        if (self.newsfeedMapDelegate.isActive) {
            [self switchToGuide];
        } else {
            [self switchToNewsfeed];
        }
    }];
}

- (void)dismissMapOptions {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/********************************************************************************/
#pragma mark - OTTourJoinRequestDelegate

- (void)dismissTourJoinRequestController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

/********************************************************************************/
#pragma mark - Segue
typedef NS_ENUM(NSInteger) {
    SegueIDUserProfile,
    SegueIDCreateMeeting,
    SegueIDConfirmation,
    SegueIDSelectedTour,
    SegueIDPublicTour,
    SegueIDTourOptions,
    SegueIDMapOptions,
    SegueIDTourJoinRequest,
    SegueIDQuitTour,
    SegueIDGuideSolidarity,
    SegueIDGuideSolidarityDetails
} SegueID;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *seguesDictionary = @{@"UserProfileSegue" : [NSNumber numberWithInteger:SegueIDUserProfile],
                                       @"OTCreateMeeting":[NSNumber numberWithInteger:SegueIDCreateMeeting],
                                       @"OTConfirmationPopup" : [NSNumber numberWithInteger:SegueIDConfirmation],
                                       @"OTSelectedTour" : [NSNumber numberWithInteger:SegueIDSelectedTour],
                                       @"OTPublicTourSegue" : [NSNumber numberWithInteger:SegueIDPublicTour],
                                       @"OTTourOptionsSegue" : [NSNumber numberWithInteger:SegueIDTourOptions],
                                       @"OTMapOptionsSegue": [NSNumber numberWithInteger:SegueIDMapOptions],
                                       @"OTTourJoinRequestSegue": [NSNumber numberWithInteger:SegueIDTourJoinRequest],
                                       @"QuitTourSegue": [NSNumber numberWithInteger:SegueIDQuitTour],
                                       @"GuideSegue": [NSNumber numberWithInteger:SegueIDGuideSolidarity],
                                       @"OTGuideDetailsSegue": [NSNumber numberWithInteger:SegueIDGuideSolidarityDetails]};
    
    UIViewController *destinationViewController = segue.destinationViewController;
    NSInteger segueID = [[seguesDictionary numberForKey:segue.identifier defaultValue:@-1] integerValue];
    switch (segueID) {
        case SegueIDUserProfile: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTUserViewController *controller = (OTUserViewController*)navController.topViewController;
            controller.user = (OTUser*)sender;
        } break;
        case SegueIDCreateMeeting: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTCreateMeetingViewController *controller = (OTCreateMeetingViewController*)navController.topViewController;
            controller.delegate = self;
            [controller configureWithTourId:self.tour.sid andLocation:self.mapView.region.center];
            controller.encounters = self.encounters;
        } break;
        case SegueIDConfirmation: {
            OTConfirmationViewController *controller = (OTConfirmationViewController *)destinationViewController;
            [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            controller.delegate = self;
            self.isTourRunning = NO;
            [controller configureWithTour:self.tour
                       andEncountersCount:[NSNumber numberWithUnsignedInteger:[self.encounters count]]];
        } break;
        case SegueIDSelectedTour: {
            UINavigationController *navController = (UINavigationController*)destinationViewController;
            OTTourViewController *controller = (OTTourViewController *)navController.topViewController;
            controller.tour = self.selectedTour;
            [controller configureWithTour:self.selectedTour];
        } break;
        case SegueIDPublicTour: {
            UINavigationController *navController = segue.destinationViewController;
            OTPublicTourViewController *controller = (OTPublicTourViewController *)navController.topViewController;
            controller.tour = self.selectedTour;
        } break;
        case SegueIDTourOptions: {
            OTTourOptionsViewController *controller = (OTTourOptionsViewController *)segue.destinationViewController;
            controller.tourOptionsDelegate = self;
            [controller setIsPOIVisible:self.guideMapDelegate.isActive];
            if (!CGPointEqualToPoint(self.mapPoint, CGPointZero)) {
                controller.c2aPoint = self.mapPoint;
            }
        } break;
        case SegueIDMapOptions: {
            OTMapOptionsViewController *controller = (OTMapOptionsViewController *)segue.destinationViewController;;
            controller.mapOptionsDelegate = self;
            [controller setIsPOIVisible:self.guideMapDelegate.isActive];
        } break;
        case SegueIDTourJoinRequest: {
            OTTourJoinRequestViewController *controller = (OTTourJoinRequestViewController *)segue.destinationViewController;
            controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
            [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            controller.tour = self.selectedTour;
            controller.tourJoinRequestDelegate = self;
        } break;
        case SegueIDQuitTour: {
            OTQuitTourViewController *controller = (OTQuitTourViewController *)segue.destinationViewController;
            controller.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
            [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            controller.tour = self.selectedTour;
        } break;
        case SegueIDGuideSolidarity: {
            UINavigationController *navController = segue.destinationViewController;
            OTGuideViewController *controller = (OTGuideViewController *)navController.childViewControllers[0];
            [controller setIsTourRunning:self.isTourRunning];
        } break;
        case SegueIDGuideSolidarityDetails: {
            UINavigationController *navController = (UINavigationController*)segue.destinationViewController;
            OTGuideDetailsViewController *controller = navController.childViewControllers[0];
            controller.poi = ((OTCustomAnnotation*)sender).poi;
            controller.category = [self categoryById:controller.poi.categoryId];
        } break;
        default:
            break;
    }
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)zoomToCurrentLocation:(id)sender {
    
    if (self.mapView.userLocation.location != nil) {
        CLLocationDistance distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.mapView.centerCoordinate), MKMapPointForCoordinate(self.mapView.userLocation.coordinate));
        BOOL animatedSetCenter = (distance < MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS);
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:animatedSetCenter];
    }
}

static bool isShowingOptions = NO;
- (IBAction)launcherTour:(UIButton *)sender {
    
    isShowingOptions = !isShowingOptions;
    [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
}

- (IBAction)createTour:(id)sender {
    [self launcherTour:self.launcherButton];
    self.launcherButton.hidden = YES;
    
    [self showNewTourStart];
}

- (IBAction)showPOI:(id)sender {
    [self launcherTour:self.launcherButton];
    
    [self togglePOI];
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
    [self.pointsToSend removeAllObjects];
    if ([self.locations count] > 0) {
        OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:self.locations.lastObject];
        [self.tour.tourPoints addObject:tourPoint];
        [self.pointsToSend addObject:tourPoint];
    }
    [self sendTour];
}

- (IBAction)stopTour:(id)sender {
    [UIView animateWithDuration:0.5 animations:^(void) {
        CGRect mapFrame = self.mapView.frame;
        mapFrame.size.height = MAPVIEW_HEIGHT;
        self.mapView.frame = mapFrame;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.launcherButton.hidden = YES;
        self.createEncounterButton.hidden = YES;
        self.mapSegmentedControl.hidden = YES;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];

    }];
    [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:sender];
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

/**************************************************************************************************/
#pragma mark - Tours Table View Delegate

- (void)showTourInfo:(OTTour*)tour {
    self.selectedTour = tour;
    
    if ([self.selectedTour.joinStatus isEqualToString:@"accepted"]) {
        [self performSegueWithIdentifier:@"OTSelectedTour" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"OTPublicTourSegue" sender:self];
    }
}

- (void)showUserProfile:(NSNumber*)userId {
    [[OTAuthService new] getDetailsForUser:userId
                                   success:^(OTUser *user) {
                                       NSLog(@"got user %@", user);
                                       [self performSegueWithIdentifier:@"UserProfileSegue" sender:user];

                                   } failure:^(NSError *error) {
                                       NSLog(@"@fails getting user %@", error.description);
                                   }];
    
}

- (void)doJoinRequest:(OTTour*)tour {
    self.selectedTour = tour;
    
    if ([tour.joinStatus isEqualToString:@"not_requested"])
    {
        [self performSegueWithIdentifier:@"OTTourJoinRequestSegue" sender:nil];
    }
    else  if ([tour.joinStatus isEqualToString:@"pending"])
    {
        [self performSegueWithIdentifier:@"OTPublicTourSegue" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"QuitTourSegue" sender:self];
    }
}

/**************************************************************************************************/
#pragma mark - Segmented control
- (IBAction)changedSegmentedControlValue:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        [self showToursList];
    }
}

/**************************************************************************************************/
#pragma mark - "Screens"

- (void)showToursList {
    
    self.isTourListDisplayed = YES;

    [UIView animateWithDuration:0.2 animations:^(void) {
        CGRect mapFrame = self.mapView.frame;
        mapFrame.size.height = MAPVIEW_HEIGHT;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        self.mapSegmentedControl.hidden = YES;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }];
}

- (void)showToursMap {
    
    if (self.newsfeedMapDelegate.isActive) {
        self.isTourListDisplayed = NO;
    }
    
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height - 64.f;
    [self.mapSegmentedControl setSelectedSegmentIndex:0];
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        self.mapSegmentedControl.hidden = self.guideMapDelegate.isActive;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }];

}

#pragma mark 6.3 Tours long press on map
- (void)showMapOverlayToCreateTourAtPoint:(CGPoint)point {
    self.launcherButton.hidden = YES;
}

#pragma mark 6.4 Tours "+" press
- (void)showMapOverlayToCreateTour {
    self.launcherButton.hidden = NO;
}


#pragma mark 15.1 New Tour - start
- (void)showNewTourStart {
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height - 64.f - self.launcherView.frame.size.height;
    
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.mapSegmentedControl.hidden = YES;
        self.launcherButton.hidden = YES;
        self.launcherView.hidden = NO;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];

    }];
}

- (IBAction)hideNewTourStart {
    [UIView animateWithDuration:0.5 animations:^(void) {
        CGRect mapFrame = self.mapView.frame;
        mapFrame.size.height = MAPVIEW_HEIGHT;self.mapSegmentedControl.hidden = YES;
        self.launcherButton.hidden = NO;
        self.launcherView.hidden = YES;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
        
    }];

}

#pragma mark 15.2 New Tour - on going
- (void)showNewTourOnGoing {
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height - 64.f;
    
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.mapSegmentedControl.hidden = NO;
        self.launcherButton.hidden = YES;
        self.launcherView.hidden = YES;
        self.createEncounterButton.hidden = NO;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }];
    
}

- (void)showTourConfirmation {
    NSLog(@"showing tour confirmation");
    
    [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:nil];
}

#pragma mark - Guide

-(void)showNewTourStartDialogFromGuide {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"poi_create_tour_alert", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:@"Quitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self switchToNewsfeed];
    }];
    [alert addAction:quitAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showNewEncounterStartDialogFromGuide {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"poi_create_encounter_alert", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:@"Quitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self switchToNewsfeed];
    }];
    [alert addAction:quitAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
