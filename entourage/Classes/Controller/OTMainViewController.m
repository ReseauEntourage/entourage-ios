//
//  OTMapViewController.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

// Controller
#import "OTMainViewController.h"
#import "UIViewController+menu.h"
#import "OTCreateMeetingViewController.h"
#import "OTToursTableViewController.h"
#import "OTCalloutViewController.h"
#import "OTMapOptionsViewController.h"
#import "OTTourOptionsViewController.h"
#import "OTTourJoinRequestViewController.h"
#import "OTFeedItemViewController.h"
#import "OTQuitFeedItemViewController.h"
#import "OTGuideViewController.h"
#import "UIView+entourage.h"
#import "OTUserViewController.h"
#import "OTGuideDetailsViewController.h"
#import "OTTourCreatorViewController.h"
#import "OTEntourageCreatorViewController.h"
#import "OTEntouragesViewController.h"
#import "OTFiltersViewController.h"
#import "OTFeedItemsPagination.h"

#import "OTToursMapDelegate.h"
#import "OTGuideMapDelegate.h"

#import "KPAnnotation.h"
#import "KPClusteringController.h"
#import "JSBadgeView.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "OTEntourageAnnotation.h"

#import "OTConsts.h"

// View
#import "SVProgressHUD.h"
#import "OTFeedItemsTableView.h"
#import "OTToolbar.h"

// Model
#import "OTUser.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTEncounter.h"
#import "OTPOI.h"
#import "OTEntourageFilter.h"

// Service
#import "OTTourService.h"
#import "OTAuthService.h"
#import "OTPOIService.h"
#import "OTFeedsService.h"
#import "OTEntourageService.h"

#import "UIButton+entourage.h"
#import "UIColor+entourage.h"
#import "UILabel+entourage.h"
#import "MKMapView+entourage.h"

// Framework
#import <UIKit/UIKit.h>
#import <WYPopoverController/WYPopoverController.h>
#import <QuartzCore/QuartzCore.h>
#import "TTTTimeIntervalFormatter.h"
#import "TTTLocationFormatter.h"
#import <AudioToolbox/AudioServices.h>

// User
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"

#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "OTFeedItemFactory.h"

#define MAPVIEW_HEIGHT 160.f

#define MIN_ENTOURAGE_HEATZONE 500.0f // m

#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define TOURS_REQUEST_DISTANCE_KM 10
#define LOCATION_MIN_DISTANCE 5.f //m

#define LONGPRESS_DELTA 65.0f
#define MAX_DISTANCE 250.0 //meters


/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMainViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate, OTTourJoinRequestDelegate, OTOptionsDelegate, OTFeedItemsTableViewDelegate, OTTourCreatorDelegate, OTFeedItemQuitDelegate, OTTourTimelineDelegate, EntourageCreatorDelegate, OTFiltersViewControllerDelegate>

@property (nonatomic, weak) IBOutlet OTToolbar *footerToolbar;

// map
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapSegmentedControl;
@property (nonatomic, weak) IBOutlet OTFeedItemsTableView *tableView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) CLLocationCoordinate2D encounterLocation;

@property (nonatomic, strong) OTToursMapDelegate *toursMapDelegate;
@property (nonatomic, strong) OTGuideMapDelegate *guideMapDelegate;

@property (nonatomic, strong) NSString *entourageType;

// markers
@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic) BOOL isRegionSetted;

// tour
@property (nonatomic, assign) CGPoint mapPoint;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *pointsToSend;
@property (nonatomic, strong) NSMutableArray *closeTours;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic) BOOL isTourListDisplayed;

// tour lifecycle
@property (nonatomic, weak) IBOutlet UIButton *launcherButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *createEncounterButton;

@property (nonatomic, strong) NSMutableArray *feeds;

// tours
@property (nonatomic) CLLocationCoordinate2D requestedToursCoordinate;
@property (nonatomic, strong) NSTimer *refreshTimer;

// POI
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, strong) NSMutableArray *markers;

@property (nonatomic) OTFeedItemsPagination *currentPagination;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic, weak) IBOutlet UIButton *nouveauxFeedItemsButton;

@end

@implementation OTMainViewController {
    BOOL encounterFromTap;
}

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBar];
    [self.footerToolbar setupWithFilters];
    
    self.locations = [NSMutableArray new];
    self.pointsToSend = [NSMutableArray new];
    self.encounters = [NSMutableArray new];
    self.markers = [NSMutableArray new];
    
    self.entourageScale = 1.0;
    self.toursMapDelegate = [[OTToursMapDelegate alloc] initWithMapController:self];
    self.guideMapDelegate = [[OTGuideMapDelegate alloc] initWithMapController:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTourConfirmation) name:@kNotificationLocalTourConfirmation object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFilters) name:@kNotificationShowFilters object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoomToCurrentLocation:) name:@kNotificationShowCurrentLocation object:nil];
    
    self.mapView = [[MKMapView alloc] init];
    [self.tableView configureWithMapView:self.mapView];
    self.tableView.feedItemsDelegate = self;
    self.currentPagination = [OTFeedItemsPagination new];
    [self configureMapView];
    
    self.mapSegmentedControl.layer.cornerRadius = 5;
    [self switchToNewsfeed];
    if (self.isTourRunning) {
        [self showNewTourOnGoing];
    } else {
        [self showToursMap];
    }
    
    [self clearMap];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:kNotificationLocationUpdated object:nil];
}

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:DATA_REFRESH_RATE target:self selector:@selector(getNewFeeds) userInfo:nil repeats:YES];
    [self.refreshTimer fire];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.toursMapDelegate.isActive) {
        [self zoomToCurrentLocation:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshTimer invalidate];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self getData];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")];
}

- (void)switchToNewsfeed {
    self.toursMapDelegate.isActive = YES;
    self.guideMapDelegate.isActive = NO;
    self.mapView.delegate = self.toursMapDelegate;
    self.mapSegmentedControl.hidden = NO;
    [self clearMap];
    [self feedMapWithFeedItems];
    [self.toursMapDelegate mapView:self.mapView regionDidChangeAnimated:YES];
    if (self.isTourListDisplayed) {
        [self showToursList];
    }
    [self.footerToolbar setTitle:OTLocalizedString(@"entourages")];
}

- (void)switchToGuide {
    self.toursMapDelegate.isActive = NO;
    self.guideMapDelegate.isActive = YES;
    self.mapView.delegate = self.guideMapDelegate;
    [self clearMap];
    [self showToursMap];
    [self.guideMapDelegate mapView:self.mapView regionDidChangeAnimated:YES];
    [self.footerToolbar setTitle:OTLocalizedString(@"guideTitle")];
}

/**************************************************************************************************/
#pragma mark - Private methods
- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    return [formatter stringFromDate:date];
}

- (void)configureMapView {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance( CLLocationCoordinate2DMake(PARIS_LAT, PARIS_LON), MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
    
    [self.mapView setRegion:region animated:YES];
    
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:self.tapGestureRecognizer];
    
   	self.mapView.showsUserLocation = YES;
    [self zoomToCurrentLocation:nil];
    
    UIGestureRecognizer *longPressMapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMapOverlay:)];
    [self.mapView addGestureRecognizer:longPressMapGesture];
}

- (void)configureNavigationBar {
    //status bar
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    
    //navigation bar
    [self createMenuButton];
    UIBarButtonItem *chatButton = [self setupChatsButton];
    [chatButton setTarget:self];
    [chatButton setAction:@selector(showEntourages)];
    [self setupLogoImage];
}

- (void)showMapOverlay:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint touchPoint = [longPressGesture locationInView:self.mapView];
    
    if (self.presentedViewController)
        return;
    
    self.mapPoint = touchPoint;
    
    if (self.isTourRunning) {
        CLLocationCoordinate2D whereTap = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:whereTap.latitude longitude:whereTap.longitude];
        CLLocation *userLocation = [[CLLocation alloc]
                                    initWithLatitude:self.mapView.userLocation.coordinate.latitude
                                    longitude:self.mapView.userLocation.coordinate.longitude];
        
        CLLocationDistance distance = [location distanceFromLocation:userLocation];
        if (distance <=  MAX_DISTANCE) {
            encounterFromTap = YES;
            self.encounterLocation = whereTap;
            [self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
        } else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:OTLocalizedString(@"distance_250")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:nil];
            
            [alert addAction:defaultAction];
        }
    } else {
        if (touchPoint.x - LONGPRESS_DELTA > 0 &&
            touchPoint.x + LONGPRESS_DELTA < [UIScreen mainScreen].bounds.size.width)
        {
            self.launcherButton.hidden = NO;
            [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
        } else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
    }
}

- (void)appWillEnterBackground:(NSNotification*)note {
    NSLog(@">>>>>>>>>>>>>>>>>>>>> APP ENTERS BACKGROUND!!!");
    [self.refreshTimer invalidate];
    if (self.isTourRunning) {
        [self createLocalNotificationForTour:self.tour.uid];
    } else {
        //[self.locationManager stopUpdatingLocation];
    }
}

- (void)appWillEnterForeground:(NSNotification*)note {
    NSLog(@"<<<<<<<<<<<<<<<<<<<<< APP COMES FOREGROUND!!!");
    //[self.locationManager startUpdatingLocation];
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
- (void)getData {
    if (self.toursMapDelegate.isActive) {
        [self getFeeds];
    } else {
        [self getPOIList];
    }
}


- (void)didChangePosition {
    CLLocationDistance distance = [self mapWidthInMeters];
    
    // image width without transparent border ~70%
    double imageWidth = [UIImage imageNamed:@"heatZone"].size.width * 0.7;
    double screenWidth = [UIScreen mainScreen].bounds.size.width;
    double scale500 = (500* screenWidth)/(imageWidth *distance)  ;

    self.entourageScale = scale500;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self feedMapWithFeedItems];
    
    if (![self.mapView showsUserLocation]) {
        [self zoomToCurrentLocation:nil];
    }
    
    // check if we need to make a new request
    CLLocationDistance moveDistance = (MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.requestedToursCoordinate), MKMapPointForCoordinate(self.mapView.centerCoordinate))) / 1000.0f;
    if (moveDistance < TOURS_REQUEST_DISTANCE_KM / 4) {
        return;
    }
    //NSLog(@"Main: position did change = > getFeeds");
    self.currentPagination.beforeDate = [NSDate date];
    [self getFeeds];
}


- (CLLocationDistance)mapWidthInMeters {
    CLLocationDegrees deltaLongitude = self.mapView.region.span.longitudeDelta;
    CGFloat latitudeCircumference = 40075160 * cos(self.mapView.region.center.latitude * M_PI / 180);
    return deltaLongitude * latitudeCircumference/360;
}

- (void)forceGetNewData {
    NSLog(@"Forcing get new data.");
    self.isRefreshing = NO;
    [self getNewFeeds];
}

- (void)getNewFeeds {
//#warning
    //NSLog(@"Attempt to getNewFeeds.\n\n");
    if (self.isRefreshing)
        return;
    self.isRefreshing = YES;
    
    __block CLLocationCoordinate2D oldRequestedCoordinate;
    oldRequestedCoordinate.latitude = self.requestedToursCoordinate.latitude;
    oldRequestedCoordinate.longitude = self.requestedToursCoordinate.longitude;
    self.requestedToursCoordinate = self.mapView.centerCoordinate;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    OTEntourageFilter *entourageFilter = [OTEntourageFilter sharedInstance];
    
    BOOL showTours = [[entourageFilter valueForFilter:kEntourageFilterEntourageShowTours] boolValue];
    BOOL myEntouragesOnly = [[entourageFilter valueForFilter:kEntourageFilterEntourageOnlyMyEntourages] boolValue];

    
    NSDictionary *filterDictionary = @{
                                       @"before" : [NSDate date],
                                       @"latitude": @(self.requestedToursCoordinate.latitude),
                                       @"longitude": @(self.requestedToursCoordinate.longitude),
                                       @"distance": @TOURS_REQUEST_DISTANCE_KM,
                                       @"tour_types": [entourageFilter getTourTypes],
                                       @"entourage_types": [entourageFilter getEntourageTypes],
                                       @"show_tours": showTours ? @"true" : @"false",
                                       @"show_my_entourages_only" : myEntouragesOnly ? @"true" : @"false",
                                       @"time_range" : [entourageFilter valueForFilter:kEntourageFilterTimeframe]
                                       };
    NSLog(@"Getting new data ...");
    [[OTFeedsService new] getAllFeedsWithParameters:filterDictionary
                                            success:^(NSMutableArray *feeds) {
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                self.isRefreshing = NO;
                                                
                                                if (!feeds.count || !didGetAnyData) {
                                                    return;
                                                }
                                                
                                                NSUInteger existingItemsCount = [self.tableView itemsCount];
                                                [self.tableView addFeedItems:feeds];
                                                NSUInteger updatedItemsCount = [self.tableView itemsCount];
                                                if (updatedItemsCount > existingItemsCount) {
                                                    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                    CGRect cellRect = [self.tableView rectForRowAtIndexPath:firstIndexPath];
                                                    BOOL completelyVisible = CGRectContainsRect(self.tableView.bounds, cellRect);
                                                    if (!completelyVisible)
                                                        self.nouveauxFeedItemsButton.hidden = NO;
                                                }
                                                self.feeds = [[self.tableView items] mutableCopy];
                                                [self feedMapWithFeedItems];
                                                [self.tableView reloadData];
                                            } failure:^(NSError *error) {
                                                NSLog(@"Error getting feeds: %@", error.description);
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                self.requestedToursCoordinate = oldRequestedCoordinate;
                                                [self registerObserver];
                                                [self.indicatorView setHidden:YES];
                                                self.isRefreshing = NO;
                                            }];

}

- (void)getFeeds {
    
    if (self.currentPagination.isLoading)
        return;
    self.currentPagination.isLoading = YES;

    __block CLLocationCoordinate2D oldRequestedCoordinate;
    oldRequestedCoordinate.latitude = self.requestedToursCoordinate.latitude;
    oldRequestedCoordinate.longitude = self.requestedToursCoordinate.longitude;
    self.requestedToursCoordinate = self.mapView.centerCoordinate;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    OTEntourageFilter *entourageFilter = [OTEntourageFilter sharedInstance];
    
    BOOL showTours = [[entourageFilter valueForFilter:kEntourageFilterEntourageShowTours] boolValue];
    BOOL myEntouragesOnly = [[entourageFilter valueForFilter:kEntourageFilterEntourageOnlyMyEntourages] boolValue];
    if (!self.currentPagination.beforeDate)
        self.currentPagination.beforeDate = [NSDate date];
    
    NSDictionary *filterDictionary = @{  //@"page": @(self.currentPagination.page),
                                         //@"per": @20,//FEEDITEMS_PER_PAGE,
                                         @"before" : self.currentPagination.beforeDate,
                                         @"latitude": @(self.requestedToursCoordinate.latitude),
                                         @"longitude": @(self.requestedToursCoordinate.longitude),
                                         @"distance": @TOURS_REQUEST_DISTANCE_KM,
                                         @"tour_types": [entourageFilter getTourTypes],
                                         @"entourage_types": [entourageFilter getEntourageTypes],
                                         @"show_tours": showTours ? @"true" : @"false",
                                         @"show_my_entourages_only" : myEntouragesOnly ? @"true" : @"false",
                                         @"time_range" : [entourageFilter valueForFilter:kEntourageFilterTimeframe]
                                         };
    
        [[OTFeedsService new] getAllFeedsWithParameters:filterDictionary
                                            success:^(NSMutableArray *feeds) {
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                if (feeds.count && !didGetAnyData) {
                                                    [self showToursList];
                                                    didGetAnyData = YES;
                                                }
                                                
                                                if (!feeds.count) {
                                                    self.currentPagination.isLoading = NO;
                                                    return;
                                                }
                                                [self.indicatorView setHidden:YES];
                                                
                                                OTFeedItem *lastFeed = self.feeds.lastObject;
                                                NSLog(@"%@ > %@", lastFeed.creationDate, self.currentPagination.beforeDate);
                                                if ([lastFeed.creationDate compare:self.currentPagination.beforeDate] != NSOrderedDescending) {
                                                    self.feeds = feeds;
                                                    [self.tableView removeAll];
                                                } else {
                                                    [self.feeds addObjectsFromArray:feeds];
                                                }

                                                [self.tableView addFeedItems:feeds];
                                                [self feedMapWithFeedItems];
                                                  //[self feedMapViewWithEncounters];
                                                [self.tableView reloadData];
                                                 self.currentPagination.isLoading = NO;
                                                
                                            } failure:^(NSError *error) {
                                                NSLog(@"Error getting feeds: %@", error.description);
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                self.requestedToursCoordinate = oldRequestedCoordinate;
                                                [self registerObserver];
                                                [self.indicatorView setHidden:YES];
                                                 self.currentPagination.isLoading = NO;
                                            }];
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
                                         NSLog(@"Err getting POI %@", error.description);
                                     }];
}

- (void)feedMapWithFeedItems {
    if (self.toursMapDelegate.isActive) {
        self.toursMapDelegate.drawnTours = [[NSMapTable alloc] init];
        NSMutableArray *annotations = [NSMutableArray new];
        
        //draw entoruages first
        for (OTFeedItem *feedItem in self.feeds) {
            if ([feedItem isKindOfClass:[OTEntourage class]]) {
                OTEntourageAnnotation *pointAnnotation = [[OTEntourageAnnotation alloc] initWithEntourage:(OTEntourage*)feedItem
                                                                                                 andScale:self.entourageScale];
                [annotations addObject:pointAnnotation];
            }
        }
        // draw tours
        for (OTFeedItem *feedItem in self.feeds) {
            if ([feedItem isKindOfClass:[OTTour class]])
                [self drawTour:(OTTour*)feedItem];
        }
        
        // draw encounters
        for (OTEncounter *encounter in self.encounters) {
            OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
            [annotations addObject:pointAnnotation];
        }
        
        [self.clusteringController setAnnotations:annotations];
        [self.clusteringController refresh:YES force:YES];
    }
}

- (void)feedMapViewWithEncounters {
    if (self.toursMapDelegate.isActive) {
        NSMutableArray *annotations = [NSMutableArray new];
        
        for (OTEncounter *encounter in self.encounters) {
            OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
            [annotations addObject:pointAnnotation];
        }
        
        [self.clusteringController setAnnotations:annotations];
        [self.clusteringController refresh:YES force:YES];
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
    CLLocationCoordinate2D coords[[tour.tourPoints count]];
    int count = 0;
    for (OTTourPoint *point in tour.tourPoints) {
        coords[count++] = point.toLocation.coordinate;
    }
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:[tour.tourPoints count]];
    [self.toursMapDelegate.drawnTours setObject:tour forKey:polyline];
    [self.mapView addOverlay:polyline];
}

- (NSString *)encounterAnnotationToString:(OTEncounterAnnotation *)annotation {
    OTEncounter *encounter = [annotation encounter];
    NSString *cellTitle = [NSString stringWithFormat:OTLocalizedString(@"formatter_has_meet"),
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

- (void)createLocalNotificationForTour:(NSNumber*)tourId {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    localNotification.alertBody = OTLocalizedString(@"tour_ongoing");
    localNotification.alertAction = OTLocalizedString(@"Stop");
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = @{@"tourId": tourId, @"object":OTLocalizedString(@"tour_ongoing")};
    localNotification.applicationIconBadgeNumber = 0;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
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
#pragma mark - Location updates

- (void)locationUpdated:(NSNotification *)notification {
    NSArray *locations = [notification readLocations];
    for (CLLocation *newLocation in locations) {
        // location may not change so often
        if (/*self.isTourRunning &&*/ !encounterFromTap)
            self.encounterLocation = newLocation.coordinate;
        
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        double distance = 100.0f;
        if ([self.locations count] > 0) {
            CLLocation *previousLocation = self.locations.lastObject;
            distance = [newLocation distanceFromLocation:previousLocation];
        }
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20 && fabs(distance) > LOCATION_MIN_DISTANCE) {
            
            if (self.locations.count > 0 && self.isTourRunning) {
                [self addTourPointFromLocation:newLocation];
                if (self.toursMapDelegate.isActive) {
                    // draw tour line
                    CLLocationCoordinate2D coords[2];
                    coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                    coords[1] = newLocation.coordinate;
                    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
                    
                    //recenter map because tour is ongoing
                    MKCoordinateRegion region = self.mapView.region;
                    region.center = newLocation.coordinate;
                    [self.mapView setRegion:region animated:YES];
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
#pragma mark - FEED ITEMS

static bool isShowingOptions = NO;
- (IBAction)doShowLaunchingOptions:(UIButton *)sender {
    isShowingOptions = !isShowingOptions;
    [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
}

/********************************************************************************/
#pragma mark - Tours

#pragma mark  OTTourCreatorDelegate

- (void)createTour:(NSString*)tourType {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self zoomToCurrentLocation:nil];
    self.currentTourType = tourType;
    self.tour = [[OTTour alloc] initWithTourType:tourType];
    [self.pointsToSend removeAllObjects];
    
    //    if (self.locations.count == 0)
    //        [self.locations addObject:self.mapView.userLocation];
    if (self.locations.count > 0) {
        OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:self.locations.lastObject];
        [self.tour.tourPoints addObject:tourPoint];
        [self.pointsToSend addObject:tourPoint];
    }
    [self sendTour];
}

- (void)sendTour {
    [SVProgressHUD showWithStatus:OTLocalizedString(@"tour_create_sending")];
    self.launcherButton.enabled = NO;
    [[OTTourService new]
         sendTour:self.tour
         withSuccess:^(OTTour *sentTour) {
             
             [self.feeds addObject:sentTour];
             [self.tableView addFeedItems:@[sentTour]];
             [self.tableView reloadData];
             [SVProgressHUD dismiss];
             self.tour.uid = sentTour.uid;
             self.tour.distance = @0.0;
             
             self.stopButton.hidden = NO;
             self.createEncounterButton.hidden = NO;
             
             NSString *snapshotStartFilename = [NSString stringWithFormat:@SNAPSHOT_START, sentTour.uid.intValue];
             [self.mapView takeSnapshotToFile:snapshotStartFilename];
             [self showNewTourOnGoing];
             
             self.locations = [NSMutableArray new];
             //[self.locations addObject:self.mapView.userLocation];
             
             OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:self.mapView.userLocation.location];
             [self.pointsToSend addObject:tourPoint];
             self.isTourRunning = YES;
             self.launcherButton.enabled = YES;
             
             if ([self.pointsToSend count] > 0) {
                 [self performSelector:@selector(sendTourPoints:) withObject:self.pointsToSend afterDelay:0.0];
             }
             [self.footerToolbar setTitle:OTLocalizedString(@"tour_ongoing")];
         } failure:^(NSError *error) {
             [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"tour_create_error", @"")];
             NSLog(@"%@",[error localizedDescription]);
             self.launcherButton.enabled = YES;
             
         }
     ];
}

- (void)addTourPointFromLocation:(CLLocation *)location {
    CLLocation *lastLocation = self.locations.lastObject;
    self.tour.distance = @(self.tour.distance.doubleValue + [location distanceFromLocation:lastLocation]);
    OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:location];
    [self.tour.tourPoints addObject:tourPoint];
    [self.pointsToSend addObject:tourPoint];
    [self sendTourPoints:self.pointsToSend];
    
    NSLog(@"Added point (%.6f, %.6f)", tourPoint.latitude, tourPoint.longitude);
}

- (void)sendTourPoints:(NSMutableArray *)tourPoints {
    if (!tourPoints.count)
        return;
    
    __block NSArray *sentPoints = [NSArray arrayWithArray:tourPoints];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [[OTTourService new] sendTourPoint:tourPoints
                            withTourId:self.tour.uid
                           withSuccess:^(OTTour *updatedTour) {
                               NSLog(@"Sent %lu tour point(s)", (unsigned long)tourPoints.count);
                               [self.pointsToSend removeObjectsInArray:sentPoints];
                               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                           }
                               failure:^(NSError *error) {
                                   NSLog(@"%@",[error localizedDescription]);
                                   NSLog(@"NOT Sent %lu tour point(s).", (unsigned long)tourPoints.count);
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                            }
     ];
}

- (IBAction)stopTour:(id)sender {
    if (self.pointsToSend.count) {
        [self sendTourPoints:self.pointsToSend];
    }
    
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
    NSString *snapshotEndFilename = [NSString stringWithFormat:@SNAPSHOT_STOP, self.tour.uid.intValue];
    [self.mapView takeSnapshotToFile:snapshotEndFilename];
    
    [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:sender];
}

#pragma mark  OTConfirmationViewControllerDelegate

- (void)tourSent:(OTTour*)tour {
    
    //check if there is an ongoing tour
    if (self.tour == nil) {
        return;
    }
    //check if we are stoping the current ongoing tour
    if (tour != nil && tour.uid != nil) {
        if (self.tour.uid == nil || ![tour.uid isEqualToNumber:self.tour.uid]) {
            return;
        }
    }
    
    [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"tour_status_completed")];
    [self.footerToolbar setTitle:OTLocalizedString(@"entourages")];
    self.tour = nil;
    [self.pointsToSend removeAllObjects];
    [self.encounters removeAllObjects];
    
    self.launcherButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.createEncounterButton.hidden = YES;
    self.isTourRunning = NO;
    self.requestedToursCoordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
    [self clearMap];
    //[self getData];
    [self forceGetNewData];
}

- (void)tourCloseError {
    self.launcherButton.hidden = YES;
    self.createEncounterButton.hidden = NO;
}

- (void)resumeTour {
    self.isTourRunning = YES;
    self.stopButton.hidden = NO;
    self.createEncounterButton.hidden = NO;
}


/********************************************************************************/
#pragma mark - UIGestureRecognizerDelegate

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self showToursMap];
    }
}

/********************************************************************************/
#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover {
    [self.popover dismissPopoverAnimated:YES];
}

/********************************************************************************/
#pragma mark - OTCreateMeetingViewControllerDelegate

- (void)encounterSent:(OTEncounter *)encounter {
    [self dismissViewControllerAnimated:YES completion:^{
        [self feedMapViewWithEncounters];
    }];
}

/********************************************************************************/
#pragma mark - OTOptionsDelegate

- (void)createTour {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.toursMapDelegate.isActive) {
            [self performSegueWithIdentifier:@"TourCreatorSegue" sender:nil];
        } else {
            [self showAlert:OTLocalizedString(@"poi_create_tour_alert") withSegue:@"TourCreatorSegue"];
        }
    }];
}

- (void)createEncounter {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.toursMapDelegate.isActive)
            [self performSegueWithIdentifier:@"OTCreateMeeting" sender:nil];
        else
            [self showAlert:OTLocalizedString(@"poi_create_encounter_alert") withSegue:nil];
    }];
}

- (void)createDemande {
    [self createEntourageOfType:ENTOURAGE_DEMANDE withAlertMessage:OTLocalizedString(@"poi_create_demande_alert")];
}

- (void)createContribution {
    [self createEntourageOfType:ENTOURAGE_CONTRIBUTION withAlertMessage:OTLocalizedString(@"poi_create_contribution_alert")];
}

- (void) createEntourageOfType:(NSString *)entourageType withAlertMessage:(NSString *)message {
    self.entourageType = entourageType;
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.toursMapDelegate.isActive) {
            [self performSegueWithIdentifier:@"EntourageCreator" sender:nil];
        } else {
            [self showAlert:message withSegue:@"EntourageCreator"];
        }
    }];
}

- (void)togglePOI {
    [self dismissViewControllerAnimated:NO
                             completion:^{
                                 if (self.toursMapDelegate.isActive) {
                                     [self switchToGuide];
                                 } else {
                                     [self switchToNewsfeed];
                                 }
                             }];
}

- (void)dismissOptions {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.isTourRunning) {
            [self showNewTourOnGoing];
        }
    }];
}

/********************************************************************************/
#pragma mark - EntourageCreatorDelegate

- (void)didCreateEntourage {
    [self dismissViewControllerAnimated:YES completion:^{
       [self forceGetNewData];
    }];
}

/********************************************************************************/
#pragma mark - OTTourJoinRequestDelegate

- (void)dismissTourJoinRequestController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

/********************************************************************************/
#pragma mark - OTFeedItemQuitDelegate

- (void)didQuitFeedItem:(OTFeedItem *)item {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

/**************************************************************************************************/
#pragma mark - OTTourDetailsOptionsDelegate

- (void)promptToCloseTour {
    [self dismissViewControllerAnimated:NO completion:^{
        [self stopTour:nil];
    }];
}

/**************************************************************************************************/
#pragma mark - OTFiltersViewControllerDelegate

- (void)filterChanged {
    self.currentPagination.beforeDate = nil;
    self.feeds = [NSMutableArray new];
    [self.tableView removeAll];
    [self.tableView reloadData];
    [self getData];
}

/**************************************************************************************************/
#pragma mark - Actions

- (void)showFilters {
    [self performSegueWithIdentifier:@"FiltersSegue" sender:self];
}

- (void)zoomToCurrentLocation:(id)sender {
    
    if (self.mapView.userLocation.location != nil) {
        CLLocationDistance distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.mapView.centerCoordinate), MKMapPointForCoordinate(self.mapView.userLocation.coordinate));
        BOOL animatedSetCenter = (distance < MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS);
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:animatedSetCenter];
    }
}

- (IBAction)doShowNewFeedItems:(UIButton*)sender {
    self.nouveauxFeedItemsButton.hidden = YES;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:YES];
}


/**************************************************************************************************/
#pragma mark - Feeds Table View Delegate

- (void)loadMoreData {
    self.currentPagination.beforeDate = ((OTFeedItem*)self.feeds.lastObject).creationDate;
    [self getData];
}

- (void)showFeedInfo:(OTFeedItem *)feedItem {
    self.selectedFeedItem = feedItem;
    
    [self performSegueWithIdentifier:@"OTSelectedTour" sender:self];
}

- (void)showUserProfile:(NSNumber*)userId {
    [[OTAuthService new] getDetailsForUser:userId
                                   success:^(OTUser *user) {
                                       [self performSegueWithIdentifier:@"UserProfileSegue" sender:user];
                                       
                                   } failure:^(NSError *error) {
                                       NSLog(@"@fails getting user %@", error.description);
                                   }];
    
}

- (void)sendJoinRequest:(OTFeedItem*)feedItem {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:feedItem] getStateTransition] sendJoinRequest:^(OTTourJoiner *joiner) {
        [SVProgressHUD dismiss];
        feedItem.joinStatus = JOIN_PENDING;
        [self performSegueWithIdentifier:@"OTTourJoinRequestSegue" sender:nil];
        [self.tableView reloadData];
    } orFailure:^(NSError *error, BOOL isTour) {
        NSLog(@"Error sending tour join request: %@", error.description);
        [SVProgressHUD dismiss];
        if(!isTour)
            [self dismissViewControllerAnimated:YES completion:^{
                [SVProgressHUD showErrorWithStatus:[error.userInfo valueForKey:@"JSONResponseSerializerWithDataKey"]];
            }];
    }];
}

- (void)doJoinRequest:(OTFeedItem*)feedItem {
    self.selectedFeedItem = feedItem;
    FeedItemState currentState = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] getState];
    switch (currentState) {
        case FeedItemStateJoinAccepted:
            [self performSegueWithIdentifier:@"QuitFeedItemSegue" sender:self];
            break;
        case FeedItemStateJoinNotRequested:
            [self sendJoinRequest:feedItem];
            break;
        case FeedItemStateJoinPending:
            [self performSegueWithIdentifier:@"OTSelectedTour" sender:self];
            break;
        case FeedItemStateOngoing:
            if (self.isTourRunning && feedItem.uid.intValue == self.tour.uid.intValue)
                [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:nil];
            break;
        case FeedItemStateOpen:
        case FeedItemStateClosed: {
            [[[OTFeedItemFactory createFor:feedItem] getStateTransition]
                closeWithSuccess:^(BOOL isTour) {
                    [self.tableView reloadData];
                    NSString* messageKey = isTour ? @"tour_quitted" : @"entourageQuitted";
                    [SVProgressHUD showSuccessWithStatus:OTLocalizedString(messageKey)];
                } orFailure:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"error")];
                    NSLog(@"%@",[error localizedDescription]);
                }
             ];
        } break;
        default:
            break;
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
    self.nouveauxFeedItemsButton.hidden = YES;
    if (self.toursMapDelegate.isActive) {
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

#pragma mark 15.2 New Tour - on going
- (void)showNewTourOnGoing {
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height - 64.f;
    [self.mapSegmentedControl setSelectedSegmentIndex:0];
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.mapSegmentedControl.hidden = NO;
        self.launcherButton.hidden = YES;
        self.createEncounterButton.hidden = NO;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }];
    
}

- (void)showTourConfirmation {
    if(self.isTourRunning)
        [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:nil];
}

#pragma mark - Guide

- (void)showAlert:(NSString *)feedItemAlertMessage withSegue:(NSString *)segueID {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:feedItemAlertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"cancelAlert")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];
    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"quitAlert")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        [self switchToNewsfeed];
        if([segueID class] != [NSNull class])
            [self performSegueWithIdentifier:segueID sender:nil];
    }];
    [alert addAction:quitAction];
    [self presentViewController:alert animated:YES completion:nil];
}

/********************************************************************************/
#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationViewController = segue.destinationViewController;
    if([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTUserViewController *controller = (OTUserViewController*)navController.topViewController;
        controller.user = (OTUser*)sender;
    }
    else if([segue.identifier isEqualToString:@"OTCreateMeeting"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTCreateMeetingViewController *controller = (OTCreateMeetingViewController*)navController.topViewController;
        controller.delegate = self;
        [controller configureWithTourId:self.tour.uid andLocation:self.encounterLocation];
        controller.encounters = self.encounters;
        encounterFromTap = NO;
    }
    else if([segue.identifier isEqualToString:@"OTConfirmationPopup"]) {
        OTConfirmationViewController *controller = (OTConfirmationViewController *)destinationViewController;
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.view.backgroundColor = [UIColor appModalBackgroundColor];
        controller.delegate = self;
        self.isTourRunning = NO;
        [controller configureWithTour:self.tour
                   andEncountersCount:[NSNumber numberWithUnsignedInteger:[self.encounters count]]];
    }
    else if([segue.identifier isEqualToString:@"OTSelectedTour"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTFeedItemViewController *controller = (OTFeedItemViewController *)navController.topViewController;
        controller.feedItem = (OTFeedItem*)self.selectedFeedItem;
    }
    else if([segue.identifier isEqualToString:@"OTTourOptionsSegue"]) {
        OTTourOptionsViewController *controller = (OTTourOptionsViewController *)destinationViewController;
        controller.optionsDelegate = self;
        [controller setIsPOIVisible:self.guideMapDelegate.isActive];
        if (!CGPointEqualToPoint(self.mapPoint, CGPointZero)) {
            controller.fingerPoint = self.mapPoint;
            self.mapPoint = CGPointZero;
        }
    }
    else if([segue.identifier isEqualToString:@"OTMapOptionsSegue"]) {
        OTMapOptionsViewController *controller = (OTMapOptionsViewController *)segue.destinationViewController;;
        if (!CGPointEqualToPoint(self.mapPoint, CGPointZero)) {
            controller.fingerPoint = self.mapPoint;
            self.mapPoint = CGPointZero;
        }
        controller.optionsDelegate = self;
        [controller setIsPOIVisible:self.guideMapDelegate.isActive];
    }
    else if([segue.identifier isEqualToString:@"OTTourJoinRequestSegue"]) {
        OTTourJoinRequestViewController *controller = (OTTourJoinRequestViewController *)destinationViewController;
        controller.view.backgroundColor = [UIColor appModalBackgroundColor];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.feedItem = self.selectedFeedItem;
        controller.tourJoinRequestDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"QuitFeedItemSegue"]) {
        OTQuitFeedItemViewController *controller = (OTQuitFeedItemViewController *)destinationViewController;
        controller.view.backgroundColor = [UIColor appModalBackgroundColor];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.feedItem = self.selectedFeedItem;
        controller.feedItemQuitDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"GuideSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        OTGuideViewController *controller = (OTGuideViewController *)navController.childViewControllers[0];
        [controller setIsTourRunning:self.isTourRunning];
    }
    else if([segue.identifier isEqualToString:@"OTGuideDetailsSegue"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTGuideDetailsViewController *controller = navController.childViewControllers[0];
        controller.poi = ((OTCustomAnnotation*)sender).poi;
        controller.category = [self categoryById:controller.poi.categoryId];
    }
    else if([segue.identifier isEqualToString:@"TourCreatorSegue"]) {
        OTTourCreatorViewController *controller = (OTTourCreatorViewController *)destinationViewController;
        controller.view.backgroundColor = [UIColor clearColor];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.tourCreatorDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"EntourageCreator"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTEntourageCreatorViewController *controller = (OTEntourageCreatorViewController *)navController.childViewControllers[0];
        controller.type = self.entourageType;
        CLLocationDegrees lat = self.mapView.userLocation.coordinate.latitude;
        CLLocationDegrees lon = self.mapView.userLocation.coordinate.longitude;
        CLLocation *location = [[CLLocation alloc] initWithLatitude: lat
                                                          longitude:lon];
        controller.location = location;
        controller.entourageCreatorDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"EntouragesSegue"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTEntouragesViewController *controller = (OTEntouragesViewController*)navController.topViewController;
        controller.mainViewController = self;
    }
    else if([segue.identifier isEqualToString:@"FiltersSegue"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTFiltersViewController *controller = (OTFiltersViewController*)navController.topViewController;
        OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
        controller.isProUser = [currentUser.type isEqualToString:USER_TYPE_PRO];
        controller.delegate = self;
    }
}

@end