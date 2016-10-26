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
#import "OTCalloutViewController.h"
#import "OTMapOptionsViewController.h"
#import "OTTourOptionsViewController.h"
#import "OTQuitFeedItemViewController.h"
#import "OTGuideViewController.h"
#import "UIView+entourage.h"
#import "OTUserViewController.h"
#import "OTGuideDetailsViewController.h"
#import "OTTourCreatorViewController.h"
#import "OTEntourageEditorViewController.h"
#import "OTFeedItemFiltersViewController.h"
#import "OTFeedItemsPagination.h"
#import "OTPublicFeedItemViewController.h"
#import "OTActiveFeedItemViewController.h"
#import "OTMyEntouragesViewController.h"
#import "OTToursMapDelegate.h"
#import "OTGuideMapDelegate.h"
#import "JSBadgeView.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "OTConsts.h"
#import "SVProgressHUD.h"
#import "OTFeedItemsTableView.h"
#import "OTToolbar.h"
#import "OTUser.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTEncounter.h"
#import "OTPOI.h"
#import "OTTourService.h"
#import "OTAuthService.h"
#import "OTPOIService.h"
#import "OTFeedsService.h"
#import "OTEntourageService.h"
#import "UIButton+entourage.h"
#import "UIColor+entourage.h"
#import "UILabel+entourage.h"
#import "MKMapView+entourage.h"
#import <UIKit/UIKit.h>
#import <WYPopoverController/WYPopoverController.h>
#import <QuartzCore/QuartzCore.h>
#import "TTTTimeIntervalFormatter.h"
#import "TTTLocationFormatter.h"
#import <AudioToolbox/AudioServices.h>
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "OTFeedItemFactory.h"
#import "OTOngoingTourService.h"
#import "OTMapDelegateProxyBehavior.h"
#import "OTOverlayFeederBehavior.h"
#import "OTTapEntourageBehavior.h"
#import "OTJoinBehavior.h"
#import "OTNewsFeedsFilter.h"
#import "OTStatusChangedBehavior.h"
#import "OTEditEntourageBehavior.h"
#import "OTBadgeNumberService.h"
#import "UIBarButtonItem+Badge.h"

#define MAPVIEW_HEIGHT 160.f

#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define FEEDS_REQUEST_DISTANCE_KM 10
#define LOCATION_MIN_DISTANCE 5.f //m

#define LONGPRESS_DELTA 65.0f
#define MAX_DISTANCE 250.0 //meters

@interface OTMainViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate, OTOptionsDelegate, OTFeedItemsTableViewDelegate, OTTourCreatorDelegate, OTFeedItemQuitDelegate, EntourageEditorDelegate, OTFeedItemsFilterDelegate>

@property (nonatomic, weak) IBOutlet OTToolbar *footerToolbar;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapSegmentedControl;
@property (nonatomic, weak) IBOutlet OTFeedItemsTableView *tableView;
@property (nonatomic, weak) IBOutlet OTMapDelegateProxyBehavior* mapDelegateProxy;
@property (nonatomic, weak) IBOutlet OTOverlayFeederBehavior* overlayFeeder;
@property (nonatomic, weak) IBOutlet OTTapEntourageBehavior* tapEntourage;
@property (nonatomic, weak) IBOutlet OTJoinBehavior* joinBehavior;
@property (nonatomic, weak) IBOutlet OTStatusChangedBehavior* statusChangedBehavior;
@property (nonatomic, weak) IBOutlet OTEditEntourageBehavior* editEntourgeBehavior;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) CLLocationCoordinate2D encounterLocation;
@property (nonatomic, strong) OTToursMapDelegate *toursMapDelegate;
@property (nonatomic, strong) OTGuideMapDelegate *guideMapDelegate;
@property (nonatomic, strong) NSString *entourageType;
@property (nonatomic, strong) NSMutableArray *encounters;
@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic) BOOL isRegionSetted;
@property (nonatomic, assign) CGPoint mapPoint;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *pointsToSend;
@property (nonatomic, strong) NSMutableArray *closeTours;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic) BOOL isTourListDisplayed;
@property (nonatomic, weak) IBOutlet UIButton *launcherButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *createEncounterButton;
@property (nonatomic, strong) NSMutableArray *feeds;
@property (nonatomic) CLLocationCoordinate2D requestedToursCoordinate;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, strong) NSMutableArray *markers;
@property (nonatomic) OTFeedItemsPagination *currentPagination;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic, weak) IBOutlet UIButton *nouveauxFeedItemsButton;
@property (nonatomic, strong) OTNewsFeedsFilter *currentFilter;
@property (nonatomic) BOOL isFirstLoad;

@end

@implementation OTMainViewController {
    BOOL encounterFromTap;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstLoad = YES;
    self.feeds = [NSMutableArray new];
    [self configureNavigationBar];
    [self.footerToolbar setupWithFilters];
    self.currentFilter = [OTNewsFeedsFilter new];
    self.locations = [NSMutableArray new];
    self.pointsToSend = [NSMutableArray new];
    self.encounters = [NSMutableArray new];
    self.markers = [NSMutableArray new];
    self.mapView = [[MKMapView alloc] init];
    self.mapDelegateProxy.mapView = self.mapView;
    self.overlayFeeder.mapView = self.mapView;
    [self.mapDelegateProxy initialize];
    self.tapEntourage.mapView = self.mapView;
    self.toursMapDelegate = [[OTToursMapDelegate alloc] initWithMapController:self];
    self.guideMapDelegate = [[OTGuideMapDelegate alloc] initWithMapController:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTourConfirmation) name:@kNotificationLocalTourConfirmation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFilters) name:@kNotificationShowFilters object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoomToCurrentLocation:) name:@kNotificationShowCurrentLocation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushReceived) name:@kNotificationPushReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:kNotificationLocationUpdated object:nil];
    [self.tableView configureWithMapView:self.mapView];
    self.tableView.feedItemsDelegate = self;
    self.currentPagination = [OTFeedItemsPagination new];
    [self configureMapView];
    self.mapSegmentedControl.layer.cornerRadius = 5;
    [self switchToNewsfeed];
    if ([OTOngoingTourService sharedInstance].isOngoing)
        [self showNewTourOnGoing];
    else
        [self showToursMap];
    [self clearMap];
    if ([OTOngoingTourService sharedInstance].isOngoing) {
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
}

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:DATA_REFRESH_RATE target:self selector:@selector(getNewFeeds) userInfo:nil repeats:YES];
    [self.refreshTimer fire];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshTimer invalidate];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self getData:NO];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")];
}

- (IBAction)dismissFeedItemJoinRequestController {
    [self.tableView reloadData];
}

- (void)switchToNewsfeed {
    self.toursMapDelegate.isActive = YES;
    self.guideMapDelegate.isActive = NO;
    [self.mapDelegateProxy.delegates addObject:self.toursMapDelegate];
    [self.mapDelegateProxy.delegates removeObject:self.guideMapDelegate];
    self.mapSegmentedControl.hidden = NO;
    [self clearMap];
    [self feedMapWithFeedItems];
    [self.toursMapDelegate mapView:self.mapView regionDidChangeAnimated:YES];
    if (self.isTourListDisplayed)
        [self showToursList];
    [self.footerToolbar setupWithFilters];
    [self.footerToolbar setTitle:OTLocalizedString(@"entourages")];
}

- (void)switchToGuide {
    self.toursMapDelegate.isActive = NO;
    self.guideMapDelegate.isActive = YES;
    [self.mapDelegateProxy.delegates removeObject:self.toursMapDelegate];
    [self.mapDelegateProxy.delegates addObject:self.guideMapDelegate];
    [self clearMap];
    [self showToursMap];
    [self.guideMapDelegate mapView:self.mapView regionDidChangeAnimated:YES];
    [self.footerToolbar setupDefault];
    [self.footerToolbar setTitle:OTLocalizedString(@"guideTitle")];
}

#pragma mark - Private methods

- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    return [formatter stringFromDate:date];
}

- (void)configureMapView {
    self.mapView.showsPointsOfInterest = NO;
   	self.mapView.showsUserLocation = YES;
    self.mapView.pitchEnabled = NO;
    MKCoordinateRegion region;
    if([OTLocationManager sharedInstance].currentLocation)
        region = MKCoordinateRegionMakeWithDistance([OTLocationManager sharedInstance].currentLocation.coordinate, MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
    else
        region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(PARIS_LAT, PARIS_LON), MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
    [self.mapView setRegion:region animated:NO];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:self.tapGestureRecognizer];
    for(UIView *view in self.mapView.subviews)
        for(UIGestureRecognizer *recognizer in view.gestureRecognizers)
            if([recognizer class] == [UILongPressGestureRecognizer class])
                [view removeGestureRecognizer:recognizer];
    UIGestureRecognizer *longPressMapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMapOverlay:)];
    [self.mapView addGestureRecognizer:longPressMapGesture];
}

- (void)configureNavigationBar {
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
    [self createMenuButton];
    [self setupChatsButtonWithTarget:self andSelector:@selector(showEntourages)];
    [self setupLogoImageWithTarget:self andSelector:@selector(logoTapped)];
}

- (void)logoTapped {
    if(self.toursMapDelegate.isActive)
       [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    else {
        self.isTourListDisplayed = YES;
        [self switchToNewsfeed];
    }
}

- (void)showMapOverlay:(UILongPressGestureRecognizer *)longPressGesture {
    CGPoint touchPoint = [longPressGesture locationInView:self.mapView];
    if (self.presentedViewController)
        return;
    self.mapPoint = touchPoint;
    if ([OTOngoingTourService sharedInstance].isOngoing) {
        CLLocationCoordinate2D whereTap = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:whereTap.latitude longitude:whereTap.longitude];
        CLLocation *userLocation = [OTLocationManager sharedInstance].currentLocation;
        CLLocationDistance distance = [location distanceFromLocation:userLocation];
        if (distance <=  MAX_DISTANCE) {
            encounterFromTap = YES;
            self.encounterLocation = whereTap;
            [Flurry logEvent:@"HiddenButtonsOverlayPress"];
            [self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
        } else {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:OTLocalizedString(@"distance_250") preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
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
    [self.refreshTimer invalidate];
    if ([OTOngoingTourService sharedInstance].isOngoing)
        [self createLocalNotificationForTour:self.tour.uid];
}

- (void)showEntourages {
    [Flurry logEvent:@"GoToMessages"];
    [self performSegueWithIdentifier:@"MyEntouragesSegue" sender:self];
}

- (void)registerObserver {
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"") options:NSKeyValueObservingOptionNew context:nil];
}

- (void)getData:(BOOL)moreFeeds {
    if (self.toursMapDelegate.isActive)
        [self getFeeds:moreFeeds];
    else
        [self getPOIList];
}

- (void)didChangePosition {
    CLLocationDistance moveDistance = (MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.requestedToursCoordinate), MKMapPointForCoordinate(self.mapView.centerCoordinate))) / 1000.0f;
    if (moveDistance < FEEDS_REQUEST_DISTANCE_KM / 4)
        return;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self feedMapWithFeedItems];
    self.currentPagination.beforeDate = [NSDate date];
    [self getFeeds:NO];
}

- (IBAction)forceGetNewData {
    NSLog(@"Forcing get new data.");
    self.isRefreshing = NO;
    [self getNewFeeds];
}

- (void)getNewFeeds {
    if (self.isRefreshing)
        return;
    self.isRefreshing = YES;
    
    __block CLLocationCoordinate2D oldRequestedCoordinate;
    oldRequestedCoordinate.latitude = self.requestedToursCoordinate.latitude;
    oldRequestedCoordinate.longitude = self.requestedToursCoordinate.longitude;
    self.requestedToursCoordinate = self.mapView.centerCoordinate;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDictionary *filterDictionary = [self.currentFilter toDictionaryWithBefore:[NSDate date] andLocation:self.requestedToursCoordinate];
    NSLog(@"Getting new data ...");
    [self.tableView loadBegun];
    [[OTFeedsService new] getAllFeedsWithParameters:filterDictionary success:^(NSMutableArray *feeds) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.isRefreshing = NO;
        if (!feeds.count)
            return;
        //NSUInteger existingItemsCount = [self.tableView itemsCount];
        [self.tableView addFeedItems:feeds];
#warning hide per francois request
        //NSUInteger updatedItemsCount = [self.tableView itemsCount];
        if (false) { //updatedItemsCount > existingItemsCount) {
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            CGRect cellRect = [self.tableView rectForRowAtIndexPath:firstIndexPath];
            BOOL completelyVisible = CGRectContainsRect(self.tableView.bounds, cellRect);
            if (!completelyVisible)
                ;//self.nouveauxFeedItemsButton.hidden = NO;
        }
        self.feeds = [[self.tableView items] mutableCopy];
        [self feedMapWithFeedItems];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"Error getting feeds: %@", error.description);
        if(error.code == NSURLErrorNotConnectedToInternet)
            [self.tableView setNoConnection];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.requestedToursCoordinate = oldRequestedCoordinate;
        [self registerObserver];
        [self.indicatorView setHidden:YES];
        self.isRefreshing = NO;
    }];
}

- (void)getFeeds:(BOOL)moreFeeds {
    if (self.currentPagination.isLoading)
        return;
    self.currentPagination.isLoading = YES;

    __block CLLocationCoordinate2D oldRequestedCoordinate;
    oldRequestedCoordinate.latitude = self.requestedToursCoordinate.latitude;
    oldRequestedCoordinate.longitude = self.requestedToursCoordinate.longitude;
    self.requestedToursCoordinate = self.mapView.centerCoordinate;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (!self.currentPagination.beforeDate)
        self.currentPagination.beforeDate = [NSDate date];
    NSDictionary *filterDictionary = [self.currentFilter toDictionaryWithBefore:self.currentPagination.beforeDate andLocation:self.requestedToursCoordinate];
    [self.tableView loadBegun];
    [[OTFeedsService new] getAllFeedsWithParameters:filterDictionary success:^(NSMutableArray *feeds) {
        self.currentPagination.isLoading = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (feeds.count && self.isFirstLoad) {
            self.isFirstLoad = NO;
            [self showToursList];
        }
        if(!moreFeeds) {
            [self.tableView removeAll];
            [self.feeds removeAllObjects];
            [self.overlayFeeder updateOverlays:@[]];
        }
        [self.feeds addObjectsFromArray:feeds];
        [self.tableView addFeedItems:feeds];
        [self.tableView reloadData];
        if(self.tableView.items.count == 0)
            [self.tableView setNoFeeds];
        [self feedMapWithFeedItems];
        [self.indicatorView setHidden:YES];
    } failure:^(NSError *error) {
        if(!moreFeeds) {
            [self.tableView removeAll];
            [self.feeds removeAllObjects];
            [self.overlayFeeder updateOverlays:@[]];
            [self.tableView reloadData];
            [self.tableView setNoFeeds];
        }
        if(error.code == NSURLErrorNotConnectedToInternet)
           [self.tableView setNoConnection];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.requestedToursCoordinate = oldRequestedCoordinate;
        [self registerObserver];
        self.currentPagination.isLoading = NO;
        [self.indicatorView setHidden:YES];
    }];
}

- (void)getPOIList {
    [[OTPoiService new] poisAroundCoordinate:self.mapView.centerCoordinate distance:[self mapHeight] success:^(NSArray *categories, NSArray *pois)
        {
            [self.indicatorView setHidden:YES];
            self.categories = categories;
            self.pois = pois;
            [self feedMapViewWithPoiArray:pois];
        } failure:^(NSError *error) {
            [self registerObserver];
            [self.indicatorView setHidden:YES];
            NSLog(@"Err getting POI %@", error.description);
    }];
}

- (void)feedMapWithFeedItems {
    if (self.toursMapDelegate.isActive) {
        [self.overlayFeeder updateOverlays:self.feeds];
        NSMutableArray *annotations = [NSMutableArray new];
        for (OTEncounter *encounter in self.encounters) {
            OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
            [annotations addObject:pointAnnotation];
        }
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:annotations];
    }
}

- (void)feedMapViewWithEncounters {
    if (self.toursMapDelegate.isActive) {
        NSMutableArray *annotations = [NSMutableArray new];
        for (OTEncounter *encounter in self.encounters) {
            OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
            [annotations addObject:pointAnnotation];
        }
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:annotations];
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
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:self.markers];
    }
}

- (NSString *)encounterAnnotationToString:(OTEncounterAnnotation *)annotation {
    OTEncounter *encounter = [annotation encounter];
    NSString *cellTitle = [NSString stringWithFormat:OTLocalizedString(@"formatter_has_meet"), encounter.userName, encounter.streetPersonName];
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
    OTCustomAnnotation *annotation = nil;
    if([view.annotation isKindOfClass:[OTCustomAnnotation class]])
        annotation = (OTCustomAnnotation *)view.annotation;
    if (annotation == nil) return;
    [Flurry logEvent:@"POIView"];
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
    if(!tourId)
        return;
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

#pragma mark - Location updates

- (void)locationUpdated:(NSNotification *)notification {
    NSArray *locations = [notification readLocations];
    for (CLLocation *newLocation in locations) {
        if (!encounterFromTap)
            self.encounterLocation = newLocation.coordinate;
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        double distance = 100.0f;
        if ([self.locations count] > 0) {
            CLLocation *previousLocation = self.locations.lastObject;
            distance = [newLocation distanceFromLocation:previousLocation];
        }
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20 && fabs(distance) > LOCATION_MIN_DISTANCE) {
            [self.locations addObject:newLocation];
            if (self.locations.count > 0 && [OTOngoingTourService sharedInstance].isOngoing)
                [self addTourPointFromLocation:newLocation];
        }
    }
}

- (void)clearMap {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:[self.mapView overlays]];
}

#pragma mark - FEED ITEMS

- (IBAction)doShowLaunchingOptions:(UIButton *)sender {
    NSString *eventName = @"PlusOnTourClick";
    if(![OTOngoingTourService sharedInstance].isOngoing)
        eventName = self.toursMapDelegate.isActive ? @"PlusFromFeedClick" : @"PlusFromGDSClick";
    [Flurry logEvent:eventName];
    [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
}

#pragma mark  OTTourCreatorDelegate

- (void)createTour:(NSString*)tourType {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self zoomToCurrentLocation:nil];
    self.currentTourType = tourType;
    self.tour = [[OTTour alloc] initWithTourType:tourType];
    [self.pointsToSend removeAllObjects];
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
    [[OTTourService new] sendTour:self.tour withSuccess:^(OTTour *sentTour) {
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
        OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:[OTLocationManager sharedInstance].currentLocation];
        [self.pointsToSend addObject:tourPoint];
        [OTOngoingTourService sharedInstance].isOngoing = YES;
        self.launcherButton.enabled = YES;
        if ([self.pointsToSend count] > 0)
            [self performSelector:@selector(sendTourPoints:) withObject:self.pointsToSend afterDelay:0.0];
        [self.footerToolbar setTitle:OTLocalizedString(@"tour_ongoing")];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"tour_create_error", @"")];
        NSLog(@"%@",[error localizedDescription]);
        self.launcherButton.enabled = YES;
    }];
}

- (void)addTourPointFromLocation:(CLLocation *)location {
    CLLocation *lastLocation = self.locations.lastObject;
    self.tour.distance = @(self.tour.distance.doubleValue + [location distanceFromLocation:lastLocation]);
    OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:location];
    [self.tour.tourPoints addObject:tourPoint];
    [self.pointsToSend addObject:tourPoint];
    [self sendTourPoints:self.pointsToSend];
    [self.overlayFeeder updateOverlayFor:self.tour];
}

- (void)sendTourPoints:(NSMutableArray *)tourPoints {
    if (!tourPoints.count)
        return;
    __block NSArray *sentPoints = [NSArray arrayWithArray:tourPoints];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[OTTourService new] sendTourPoint:tourPoints withTourId:self.tour.uid withSuccess:^(OTTour *updatedTour) {
        NSLog(@"Sent %lu tour point(s)", (unsigned long)tourPoints.count);
        [self.pointsToSend removeObjectsInArray:sentPoints];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.overlayFeeder updateOverlayFor:self.tour];
    } failure:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
        NSLog(@"NOT Sent %lu tour point(s).", (unsigned long)tourPoints.count);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (IBAction)stopTour:(id)sender {
    [Flurry logEvent:@"SuspendTourClick"];
    if (self.pointsToSend.count)
        [self sendTourPoints:self.pointsToSend];
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
    if (self.tour == nil)
        return;
    if (tour != nil && tour.uid != nil)
        if (self.tour.uid == nil || ![tour.uid isEqualToNumber:self.tour.uid])
            return;
    [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"tour_status_completed")];
    [self.footerToolbar setTitle:OTLocalizedString(@"entourages")];
    self.tour = nil;
    [self.pointsToSend removeAllObjects];
    [self.encounters removeAllObjects];
    self.launcherButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.createEncounterButton.hidden = YES;
    [OTOngoingTourService sharedInstance].isOngoing = NO;
    self.requestedToursCoordinate = CLLocationCoordinate2DMake(0.0f, 0.0f);
    [self clearMap];
    [self forceGetNewData];
}

- (void)tourCloseError {
    self.launcherButton.hidden = YES;
    self.createEncounterButton.hidden = NO;
}

- (void)resumeTour {
    [OTOngoingTourService sharedInstance].isOngoing = YES;
    self.stopButton.hidden = NO;
    self.createEncounterButton.hidden = NO;
}

#pragma mark - UIGestureRecognizerDelegate

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if(self.isTourListDisplayed) {
            [Flurry logEvent:@"MapClick"];
            [self showToursMap];
        }
        else if([self.tapEntourage hasTappedEntourage:sender]) {
            [Flurry logEvent:@"HeatzoneMapClick"];
            [self showToursList];
        }
    }
}

#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover {
    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark - OTCreateMeetingViewControllerDelegate

- (void)encounterSent:(OTEncounter *)encounter {
    [self dismissViewControllerAnimated:YES completion:^{
        [self feedMapViewWithEncounters];
    }];
}

#pragma mark - OTOptionsDelegate

- (void)createTour {
    void(^createBlock)() = ^() {
        if (self.toursMapDelegate.isActive)
            [self performSegueWithIdentifier:@"TourCreatorSegue" sender:nil];
        else
            [self showAlert:OTLocalizedString(@"poi_create_tour_alert") withSegue:@"TourCreatorSegue"];
    };
    if([self.presentedViewController isKindOfClass:[OTMapOptionsViewController class]])
        [self dismissViewControllerAnimated:YES completion:createBlock];
    else
        createBlock();
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
            [self performSegueWithIdentifier:@"EntourageEditor" sender:nil];
        } else {
            [self showAlert:message withSegue:@"EntourageEditor"];
        }
    }];
}

- (void)togglePOI {
    NSString *message = @"";
    if([OTOngoingTourService sharedInstance].isOngoing)
        message = self.toursMapDelegate.isActive ? @"OnTourShowGuide" : @"OnTourHideGuide";
    else
        message = self.toursMapDelegate.isActive ? @"GDSViewClick" : @"MaskGDSClick";
    [Flurry logEvent:message];
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.toursMapDelegate.isActive)
            [self switchToGuide];
        else
            [self switchToNewsfeed];
    }];
}

- (void)dismissOptions {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([OTOngoingTourService sharedInstance].isOngoing) {
            [self showNewTourOnGoing];
        }
    }];
}

#pragma mark - EntourageEditorDelegate

- (void)didEditEntourage:(OTEntourage *)entourage {
    [self dismissViewControllerAnimated:YES completion:^{
       [self forceGetNewData];
    }];
}

#pragma mark - OTFeedItemQuitDelegate

- (void)didQuitFeedItem:(OTFeedItem *)item {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - OTFeedItemsFilterDelegate

- (void)filterChanged:(OTNewsFeedsFilter *)filter {
    self.currentFilter = filter;
    self.currentPagination.beforeDate = nil;
    self.feeds = [NSMutableArray new];
    [self clearMap];
    [self.tableView removeAll];
    [self.tableView reloadData];
    [self getData:NO];
}

#pragma mark - Actions

- (void)showFilters {
    [self performSegueWithIdentifier:@"FiltersSegue" sender:self];
}

- (void)zoomToCurrentLocation:(id)sender {
    CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
    if (currentLocation) {
        CLLocationDistance distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.mapView.centerCoordinate), MKMapPointForCoordinate(currentLocation.coordinate));
        BOOL animatedSetCenter = (distance < MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS);
        [self.mapView setCenterCoordinate:currentLocation.coordinate animated:animatedSetCenter];
        if(self.toursMapDelegate.isActive && !self.isRegionSetted) {
            self.isRegionSetted = YES;
            self.currentPagination.isLoading = NO;
            [self.toursMapDelegate mapView:self.mapView regionDidChangeAnimated:YES];
        }
    }
}

- (IBAction)doShowNewFeedItems:(UIButton*)sender {
    [Flurry logEvent:@"ScrollListPage"];
    self.nouveauxFeedItemsButton.hidden = YES;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

- (void)pushReceived {
    self.navigationItem.rightBarButtonItem.badgeValue = [OTBadgeNumberService sharedInstance].badgeCount.stringValue;
}

#pragma mark - Feeds Table View Delegate

- (void)loadMoreData {
    [Flurry logEvent:@"RefreshListPage"];
    self.currentPagination.beforeDate = ((OTFeedItem*)self.feeds.lastObject).creationDate;
    [self getData:YES];
}

- (void)showFeedInfo:(OTFeedItem *)feedItem {
    self.selectedFeedItem = feedItem;
    if([[[OTFeedItemFactory createFor:feedItem] getStateInfo] isPublic]) {
        [Flurry logEvent:@"OpenEntouragePublicPage"];
        [self performSegueWithIdentifier:@"PublicFeedItemDetailsSegue" sender:self];
    }
    else {
        [Flurry logEvent:@"OpenEntourageActivePage"];
        [self performSegueWithIdentifier:@"ActiveFeedItemDetailsSegue" sender:self];
    }
}

- (void)showUserProfile:(NSNumber*)userId {
    [[OTAuthService new] getDetailsForUser:userId success:^(OTUser *user) {
        [self performSegueWithIdentifier:@"UserProfileSegue" sender:user];
    } failure:^(NSError *error) {
        NSLog(@"@fails getting user %@", error.description);
    }];
}

- (void)sendJoinRequest:(OTFeedItem*)feedItem {
    [self.joinBehavior join:feedItem];
}

- (void)doJoinRequest:(OTFeedItem*)feedItem {
    self.selectedFeedItem = feedItem;
    FeedItemState currentState = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] getState];
    switch (currentState) {
        case FeedItemStateJoinNotRequested:
            [Flurry logEvent:@"OpenEnterInContact"];
            [self sendJoinRequest:feedItem];
            break;
        case FeedItemStateJoinPending:
            [Flurry logEvent:@"PendingRequestOverlay"];
            break;
        case FeedItemStateOngoing:
            self.tour = (OTTour *)feedItem;
            [OTOngoingTourService sharedInstance].isOngoing = YES;
            [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:nil];
            break;
        case FeedItemStateJoinAccepted:
        case FeedItemStateOpen:
        case FeedItemStateClosed:
            [Flurry logEvent:@"OpenActiveCloseOverlay"];
            [self.statusChangedBehavior configureWith:feedItem];
            [self.statusChangedBehavior startChangeStatus];
            break;
        default:
            break;
    }
}

#pragma mark - Segmented control

- (IBAction)changedSegmentedControlValue:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        [Flurry logEvent:@"ListViewClick"];
        [self showToursList];
    }
    else
        [Flurry logEvent:@"MapViewClick"];
}

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
    if (self.toursMapDelegate.isActive)
        self.isTourListDisplayed = NO;
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
    if([OTOngoingTourService sharedInstance].isOngoing)
        [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:nil];
}

#pragma mark - Guide

- (void)showAlert:(NSString *)feedItemAlertMessage withSegue:(NSString *)segueID {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:feedItemAlertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"cancelAlert") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"quitAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self switchToNewsfeed];
        if([segueID class] != [NSNull class])
            [self performSegueWithIdentifier:segueID sender:nil];
    }];
    [alert addAction:quitAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.joinBehavior prepareSegueForMessage:segue])
        return;
    if([self.editEntourgeBehavior prepareSegue:segue])
        return;
    if([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
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
        [OTOngoingTourService sharedInstance].isOngoing = NO;
        [controller configureWithTour:self.tour andEncountersCount:[NSNumber numberWithUnsignedInteger:[self.encounters count]]];
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
        [controller setIsTourRunning:[OTOngoingTourService sharedInstance].isOngoing];
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
    else if([segue.identifier isEqualToString:@"EntourageEditor"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTEntourageEditorViewController *controller = (OTEntourageEditorViewController *)navController.childViewControllers[0];
        controller.type = self.entourageType;
        CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
        controller.location = currentLocation;
        controller.entourageEditorDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"FiltersSegue"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTFeedItemFiltersViewController *controller = (OTFeedItemFiltersViewController*)navController.topViewController;
        controller.filterDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"PublicFeedItemDetailsSegue"]) {
        OTPublicFeedItemViewController *controller = (OTPublicFeedItemViewController *)destinationViewController;
        controller.feedItem = self.selectedFeedItem;
    }
    else if([segue.identifier isEqualToString:@"ActiveFeedItemDetailsSegue"]) {
        OTActiveFeedItemViewController *controller = (OTActiveFeedItemViewController *)destinationViewController;
        controller.feedItem = self.selectedFeedItem;
    }
    else if([segue.identifier isEqualToString:@"MyEntouragesSegue"]) {
        OTMyEntouragesViewController *controller = (OTMyEntouragesViewController *)destinationViewController;
        controller.optionsDelegate = self;
    }
}

@end
