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
#import "OTCalloutViewController.h"
#import "OTMapOptionsViewController.h"
#import "OTTourOptionsViewController.h"
#import "OTQuitFeedItemViewController.h"
#import "UIView+entourage.h"
#import "OTUserViewController.h"
#import "OTGuideDetailsViewController.h"
#import "OTTourCreatorViewController.h"
#import "OTEntourageEditorViewController.h"
#import "OTFeedItemFiltersViewController.h"
#import "OTPublicFeedItemViewController.h"
#import "OTActiveFeedItemViewController.h"
#import "OTMyEntouragesViewController.h"
#import "OTToursMapDelegate.h"
#import "OTGuideMapDelegate.h"
#import "JSBadgeView.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"
#import "SVProgressHUD.h"
#import "OTFeedItemsTableView.h"
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
#import "UIBarButtonItem+Badge.h"
#import "OTNewsFeedsSourceDelegate.h"
#import "OTNewsFeedsSourceBehavior.h"
#import "OTTourCreatorBehavior.h"
#import "OTTourCreatorBehaviorDelegate.h"
#import "OTStartTourAnnotation.h"
#import "OTNoDataBehavior.h"
#import "OTTutorialService.h"
#import "OTUnreadMessagesService.h"
#import "OTMailSenderBehavior.h"
#import "OTSolidarityGuideFiltersViewController.h"
#import "OTSolidarityGuideFilterDelegate.h"
#import "OTCustomSegmentedBehavior.h"
#import "OTAppDelegate.h"
#import "OTSavedFilter.h"
#import "OTGuideInfoBehavior.h"
#import "OTEditEncounterBehavior.h"
#import "OTTapViewBehavior.h"
#import "OTToggleVisibleBehavior.h"
#import "OTCollectionSourceBehavior.h"
#import "OTHeatzonesCollectionSource.h"
#import "KPClusteringController.h"
#import "KPAnnotation.h"
#import "OTAnnouncement.h"
#import "OTWebViewController.h"

#define MAPVIEW_HEIGHT 224.f

#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define FEEDS_REQUEST_DISTANCE_KM 10

#define LONGPRESS_DELTA 65.0f
#define MAX_DISTANCE 250.0 //meters

@interface OTMainViewController ()
<
    UIGestureRecognizerDelegate,
    UIScrollViewDelegate,
    OTOptionsDelegate,
    OTFeedItemsTableViewDelegate,
    OTTourCreatorDelegate,
    OTFeedItemQuitDelegate,
    EntourageEditorDelegate,
    OTFeedItemsFilterDelegate,
    OTSolidarityGuideFilterDelegate,
    OTNewsFeedsSourceDelegate,
    OTTourCreatorBehaviorDelegate,
    OTHeatzonesCollectionViewDelegate,
    OTWebViewDelegate
>

@property (nonatomic, weak) IBOutlet OTFeedItemsTableView           *tableView;
@property (nonatomic, weak) IBOutlet OTMapDelegateProxyBehavior     *mapDelegateProxy;
@property (nonatomic, weak) IBOutlet OTOverlayFeederBehavior        *overlayFeeder;
@property (nonatomic, weak) IBOutlet OTTapEntourageBehavior         *tapEntourage;
@property (nonatomic, weak) IBOutlet OTTapViewBehavior              *tapViewBehavior;
@property (nonatomic, weak) IBOutlet OTJoinBehavior                 *joinBehavior;
@property (nonatomic, weak) IBOutlet OTStatusChangedBehavior        *statusChangedBehavior;
@property (nonatomic, weak) IBOutlet OTEditEntourageBehavior        *editEntourgeBehavior;
@property (nonatomic, weak) IBOutlet OTEditEncounterBehavior        *editEncounterBehavior;
@property (nonatomic, weak) IBOutlet OTNewsFeedsSourceBehavior      *newsFeedsSourceBehavior;
@property (nonatomic, weak) IBOutlet OTTourCreatorBehavior          *tourCreatorBehavior;
@property (nonatomic, weak) IBOutlet UIView                         *showSolidarityGuideView;
@property (nonatomic, weak) IBOutlet UILabel                        *solidarityGuideLabel;
@property (nonatomic, strong) MKMapView                             *mapView;
@property (nonatomic, strong) UITapGestureRecognizer                *tapGestureRecognizer;
@property (nonatomic) CLLocationCoordinate2D                        encounterLocation;
@property (nonatomic, strong) OTToursMapDelegate                    *toursMapDelegate;
@property (nonatomic, strong) OTGuideMapDelegate                    *guideMapDelegate;
@property (nonatomic, strong) NSString                              *entourageType;
@property (nonatomic, strong) NSMutableArray                        *encounters;
@property (nonatomic, strong) WYPopoverController                   *popover;
@property (nonatomic) BOOL                                          isRegionSetted;
@property (nonatomic, assign) CGPoint                               mapPoint;
@property (nonatomic, strong) CLLocation                            *tappedLocation;
@property (nonatomic) BOOL                                          isTourListDisplayed;
@property (nonatomic, weak) IBOutlet UIButton                       *launcherButton;
@property (nonatomic, weak) IBOutlet UIButton                       *stopButton;
@property (nonatomic, weak) IBOutlet UIButton                       *createEncounterButton;
@property (nonatomic, weak) IBOutlet UIButton                       *backToNewsFeedsButton;
@property (nonatomic, strong) NSArray                               *categories;
@property (nonatomic, strong) NSArray                               *pois;
@property (nonatomic, strong) NSMutableArray                        *markers;
@property (nonatomic, weak) IBOutlet UIButton                       *nouveauxFeedItemsButton;
@property (nonatomic, strong) OTNewsFeedsFilter                     *currentFilter;
@property (nonatomic, strong) OTSolidarityGuideFilter               *solidarityFilter;
@property (nonatomic) BOOL                                          isFirstLoad;
@property (nonatomic) BOOL                                          wasLoadedOnce;
@property (nonatomic) BOOL                                          noDataDisplayed;
@property (nonatomic) BOOL                                          poisDisplayed;
@property (nonatomic, weak) IBOutlet OTNoDataBehavior               *noDataBehavior;
@property (nonatomic, weak) IBOutlet OTMailSenderBehavior           *mailSender;
@property (nonatomic, weak) IBOutlet OTCustomSegmentedBehavior      *customSegmentedBehavior;
@property (nonatomic, weak) IBOutlet OTGuideInfoBehavior            *guideInfoBehavior;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior      *toggleCollectionView;
@property (nonatomic, strong) IBOutlet OTCollectionSourceBehavior   *heatzonesDataSource;
@property (nonatomic, strong) IBOutlet OTHeatzonesCollectionSource  *heatzonesCollectionDataSource;

@property (nonatomic, strong) KPClusteringController *clusteringController;
@property (nonatomic) double entourageScale;

@end

@implementation OTMainViewController
    BOOL encounterFromTap;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [[OTTutorialService new] showTutorial];
}

- (void)setup {
    self.solidarityGuideLabel.text = OTLocalizedString(@"map_options_show_guide");
    self.isFirstLoad = YES;
    self.heatzonesCollectionDataSource.heatzonesDelegate = self;
    [self.heatzonesCollectionDataSource initialize];
    [self.toggleCollectionView initialize];
    [self.toggleCollectionView toggle:NO animated:NO];
    [self.noDataBehavior initialize];
    [self.newsFeedsSourceBehavior initialize];
    [self.customSegmentedBehavior initialize];
    [self.tapViewBehavior initialize];
    
    self.newsFeedsSourceBehavior.delegate = self;
    [self.tourCreatorBehavior initialize];
    self.tourCreatorBehavior.delegate = self;
    self.newsFeedsSourceBehavior.tableDelegate = self.tableView;
    
    [self configureNavigationBar];
    self.currentFilter = [OTNewsFeedsFilter new];
    self.solidarityFilter = [OTSolidarityGuideFilter new];
    self.encounters = [NSMutableArray new];
    self.markers = [NSMutableArray new];
    self.mapView = [MKMapView new];
    self.mapDelegateProxy.mapView = self.mapView;
    self.overlayFeeder.mapView = self.mapView;
    [self.mapDelegateProxy initialize];
    self.tapEntourage.mapView = self.mapView;
    self.toursMapDelegate = [[OTToursMapDelegate alloc] initWithMapController:self];
    self.guideMapDelegate = [[OTGuideMapDelegate alloc] initWithMapController:self];
    [self.tableView configureWithMapView:self.mapView];
    self.tableView.feedItemsDelegate = self;
    [self configureMapView];
    
    [self switchToNewsfeed];
    [self reloadFeeds];
    
    self.backToNewsFeedsButton.hidden = YES;
    [self.backToNewsFeedsButton addTarget:self
                                   action:@selector(leaveGuide)
                         forControlEvents:UIControlEventTouchUpInside];
    
    if (OTSharedOngoingTour.isOngoing || [NSUserDefaults standardUserDefaults].currentOngoingTour != nil) {
        [self setupUIForTourOngoing];
    } else {
        [self showToursMap];
        [self clearMap];
        self.launcherButton.hidden = NO;
        self.stopButton.hidden = YES;
        self.createEncounterButton.hidden = YES;
    }
    
    [self.mapDelegateProxy.delegates addObject:self];
    self.entourageScale = 1.0;
    [self addObservers];
}

- (void)setupUIForTourOngoing {
    [self showNewTourOnGoing];
    [self clearMap];
    self.tourCreatorBehavior.tour = [NSUserDefaults standardUserDefaults].currentOngoingTour;
    self.launcherButton.hidden = YES;
    self.createEncounterButton.hidden = NO;
    self.stopButton.hidden = NO;
    [[OTTourService new] tourEncounters:self.tourCreatorBehavior.tour success:^(NSArray *items) {
        self.encounters = [NSMutableArray arrayWithArray:items];
    } failure:^(NSError *error) {
        NSLog(@"GET TOUR ENCOUNTERSErr: %@", error.description);
    }];
    [self feedMapViewWithEncounters];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(encounterEdited:)
                                                 name:kNotificationEncounterEdited
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(showTourConfirmation) 
                                                 name:@kNotificationLocalTourConfirmation 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(zoomToCurrentLocation:) 
                                                 name:@kNotificationShowCurrentLocation 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushReceived)
                                                 name:@kNotificationPushReceived
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdated:)
                                                 name:kNotificationLocationUpdated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(entourageCreated:)
                                                 name:kNotificationEntourageCreated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forceGetNewData)
                                                 name:@kNotificationReloadData
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendCloseMail:)
                                                 name:@kNotificationSendCloseMail
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchToGuide)
                                                 name:kSolidarityGuideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBadge)
                                                 name:[kUpdateBadgeCountNotification copy]
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(entourageUpdated:)
                                                 name:kNotificationEntourageChanged
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(associationUpdated)
                                                 name:kNotificationAssociationUpdated
                                               object:nil];
}

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.newsFeedsSourceBehavior resume];
    [self.heatzonesCollectionDataSource refresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.newsFeedsSourceBehavior pause];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.webview) {
        [self performSegueWithIdentifier:@"OTWebViewSegue" sender:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.toursMapDelegate.isActive)
        [self reloadFeeds];
    else
        [self reloadPois];
    [[NSUserDefaults standardUserDefaults] removeObserver:self
                                               forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")];
}

- (IBAction)dismissFeedItemJoinRequestController {
    [self.tableView reloadData];
}

- (void)loadHeatzonesWithItems: (NSMutableArray *) itemsTapped {
    NSMutableArray *feeds = [[NSMutableArray alloc] init];
    for (CLLocation *coordinates in itemsTapped) {
        for (OTEntourage *item in self.newsFeedsSourceBehavior.feedItems) {
            if([item isKindOfClass:[OTEntourage class]])
                if(item.location.coordinate.latitude == coordinates.coordinate.latitude &&
                   item.location.coordinate.longitude == coordinates.coordinate.longitude)
                        [feeds addObject:item];
        }
    }
    [self.toggleCollectionView toggle:[feeds count] > 0 animated:YES];
    if(feeds.count > 0)
        [self.heatzonesDataSource updateItems:feeds];
    [self.heatzonesCollectionDataSource refresh];
}

- (void)switchToNewsfeed {
    [OTLogger logEvent:@"Screen06_1FeedView"];
    [self.tableView switchToFeeds];
    [self.tableView updateItems:self.newsFeedsSourceBehavior.feedItems];
    [self.noDataBehavior switchedToNewsfeeds];
    [self.guideInfoBehavior hide];
    self.toursMapDelegate.isActive = YES;
    self.guideMapDelegate.isActive = NO;
    self.backToNewsFeedsButton.hidden = YES;
    [self.mapDelegateProxy.delegates addObject:self.toursMapDelegate];
    [self.mapDelegateProxy.delegates removeObject:self.guideMapDelegate];
    [self.customSegmentedBehavior updateVisible:YES];
    [self clearMap];
    [self feedMapWithFeedItems];
    self.showSolidarityGuideView.hidden = NO;
    if (self.isTourListDisplayed) {
        [self showToursList];
    }
}

- (void)switchToGuide {
    [self.tableView switchToGuide];
    [self.tableView updateItems:self.pois];
    [self.noDataBehavior switchedToGuide];
    self.toursMapDelegate.isActive = NO;
    self.guideMapDelegate.isActive = YES;
    self.backToNewsFeedsButton.hidden = NO;
    [self.mapDelegateProxy.delegates removeObject:self.toursMapDelegate];
    [self.mapDelegateProxy.delegates addObject:self.guideMapDelegate];
    [self.customSegmentedBehavior updateVisible:YES];
    [self clearMap];
    [self showToursMap];
    [self reloadPois];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)goToTourOptions:(id)sender {
    [OTLogger logEvent:@"PlusOnTourClick"];
    [self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
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
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
    MKCoordinateRegion region;
    if([OTLocationManager sharedInstance].currentLocation)
        region = MKCoordinateRegionMakeWithDistance([OTLocationManager sharedInstance].currentLocation.coordinate, MAPVIEW_CLICK_REGION_SPAN_X_METERS, MAPVIEW_CLICK_REGION_SPAN_Y_METERS );
    else
        region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(PARIS_LAT, PARIS_LON), MAPVIEW_CLICK_REGION_SPAN_X_METERS, MAPVIEW_CLICK_REGION_SPAN_Y_METERS );
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

- (void)leaveGuide {
    if(self.toursMapDelegate.isActive)
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    else {
        [self switchToNewsfeed];
    }}

- (void)showMapOverlay:(UILongPressGestureRecognizer *)longPressGesture {
    if(self.isTourListDisplayed)
        return;
    if(!IS_PRO_USER && !self.guideMapDelegate.isActive) {
        [self performSegueWithIdentifier:@"EntourageEditor" sender:nil];
        return;
    }
    CGPoint touchPoint = [longPressGesture locationInView:self.mapView];
    if (self.presentedViewController)
        return;
    self.mapPoint = touchPoint;
    CLLocationCoordinate2D whereTap = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    self.tappedLocation = [[CLLocation alloc] initWithLatitude:whereTap.latitude longitude:whereTap.longitude];

    if ([OTOngoingTourService sharedInstance].isOngoing) {
        encounterFromTap = YES;
        self.encounterLocation = whereTap;
        [OTLogger logEvent:@"HiddenButtonsOverlayPress"];
        if (touchPoint.x - LONGPRESS_DELTA < 0)
            self.mapPoint = CGPointMake(touchPoint.x + LONGPRESS_DELTA, touchPoint.y);
        if (touchPoint.x + LONGPRESS_DELTA > [UIScreen mainScreen].bounds.size.width)
            self.mapPoint = CGPointMake(touchPoint.x - LONGPRESS_DELTA, touchPoint.y);
        if (touchPoint.y + LONGPRESS_DELTA < 0 )
            self.mapPoint = CGPointMake(touchPoint.x, touchPoint.y + LONGPRESS_DELTA + 10);
        if (touchPoint.y + LONGPRESS_DELTA > [UIScreen mainScreen].bounds.size.height )
            self.mapPoint = CGPointMake(touchPoint.x, touchPoint.y - LONGPRESS_DELTA - 10);
        [self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
    } else {
        if (touchPoint.x - LONGPRESS_DELTA < 0)
            self.mapPoint = CGPointMake(touchPoint.x + LONGPRESS_DELTA, touchPoint.y);
        if (touchPoint.x + LONGPRESS_DELTA > [UIScreen mainScreen].bounds.size.width)
            self.mapPoint = CGPointMake(touchPoint.x - LONGPRESS_DELTA, touchPoint.y);
        if (touchPoint.y + LONGPRESS_DELTA < 0 )
            self.mapPoint = CGPointMake(touchPoint.x, touchPoint.y + LONGPRESS_DELTA + 10);
        if (touchPoint.y + LONGPRESS_DELTA > [UIScreen mainScreen].bounds.size.height )
            self.mapPoint = CGPointMake(touchPoint.x, touchPoint.y - LONGPRESS_DELTA - 10);
        self.launcherButton.hidden = NO;
        [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
    }
}

- (void)appWillEnterBackground:(NSNotification*)note {
    [self.newsFeedsSourceBehavior pause];
    if ([OTOngoingTourService sharedInstance].isOngoing)
        [self createLocalNotificationForTour: self.tourCreatorBehavior.tour.uid];
}

- (void)showEntourages {
    [OTLogger logEvent:@"GoToMessages"];
    [self performSegueWithIdentifier:@"MyEntouragesSegue" sender:self];
}

- (void)registerObserver {
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"") options:NSKeyValueObservingOptionNew context:nil];
}

- (void)reloadFeeds {
    [self.tableView loadBegun];
    [self.newsFeedsSourceBehavior reloadItemsAt:self.mapView.centerCoordinate withFilters:self.currentFilter];
    [self.toggleCollectionView toggle:NO animated:NO];
}

- (void)reloadPois {
    [self getPOIList];
}

- (void)willChangePosition {
    [self.noDataBehavior hideNoData];
}

- (void)didChangePosition {
    CLLocationDistance moveDistance = (MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.newsFeedsSourceBehavior.lastOkCoordinate), MKMapPointForCoordinate(self.mapView.centerCoordinate))) / 1000.0f;
    if(self.toursMapDelegate.isActive) {
        if (moveDistance < FEEDS_REQUEST_DISTANCE_KM / 4)
            return;
        [self reloadFeeds];
    } else
        [self reloadPois];
}

- (IBAction)forceGetNewData {
    NSLog(@"Forcing get new data.");
    [self.newsFeedsSourceBehavior getNewItems];
}

- (void)getPOIList {
    [self.noDataBehavior hideNoData];
    [SVProgressHUD show];
    [[OTPoiService new] poisWithParameters:[self.solidarityFilter toDictionaryWithDistance:[self mapHeight] Location:self.mapView.centerCoordinate] success:^(NSArray *categories, NSArray *pois)
        {
            self.categories = categories;
            self.pois = pois;
            [self.tableView updateItems:pois];
            [self feedMapViewWithPoiArray:pois];
            if(self.pois.count == 0) {
                if(!self.noDataDisplayed) {
                    [self.noDataBehavior showNoData];
                    self.noDataDisplayed = YES;
                }
            }
            else {
                if(!self.poisDisplayed) {
                    [self.guideInfoBehavior show];
                    self.poisDisplayed = YES;
                }
            }
            [SVProgressHUD dismiss];
               
        } failure:^(NSError *error) {
            [self registerObserver];
            NSLog(@"Err getting POI %@", error.description);
            self.pois.count == 0 ? [self.noDataBehavior showNoData] : [self.guideInfoBehavior show];
            [SVProgressHUD dismiss];
    }];
}

- (void)feedMapWithFeedItems {
    if (self.toursMapDelegate.isActive) {
        NSMutableArray *feedItems = [[NSMutableArray alloc] init];
        for(OTFeedItem *item in self.newsFeedsSourceBehavior.feedItems) {
            if(![item isKindOfClass:[OTAnnouncement class]]) {
                [feedItems addObject:item];
            }
        }
        [self.overlayFeeder updateOverlays:feedItems];
        NSMutableArray *annotations = [NSMutableArray new];
        for (OTEncounter *encounter in self.encounters) {
            OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
            [annotations addObject:pointAnnotation];
        }
        for(OTFeedItem *item in self.newsFeedsSourceBehavior.feedItems) {
            if([item isKindOfClass:[OTTour class]]) {
                OTStartTourAnnotation *startAnnotation = [[OTStartTourAnnotation alloc] initWithTour:(OTTour *)item];
                if(startAnnotation)
                   [annotations addObject:startAnnotation];
            }
        }
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:annotations];
    }
}

- (void)feedMapViewWithEncounters {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    OTFeedItemAuthor *author = self.tourCreatorBehavior.tour.author;
    if (currentUser.sid == nil || author.uID == nil) {
        return;
    }
    if (self.toursMapDelegate.isActive && [currentUser.sid isEqualToNumber:author.uID]) {
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
        [self.markers removeAllObjects];
        for (OTPoi *poi in array) {
            OTCustomAnnotation *annotation = [[OTCustomAnnotation alloc] initWithPoi:poi];
            [self.markers addObject:annotation];
        }
        
        [self.clusteringController setAnnotations:self.markers];
        [self.clusteringController refresh:YES force:YES];
    }
}

- (NSString *)encounterAnnotationToString:(OTEncounterAnnotation *)annotation {
    OTEncounter *encounter = [annotation encounter];
    NSString *cellTitle = [NSString stringWithFormat:OTLocalizedString(@"formatter_has_meet"), encounter.userName, encounter.streetPersonName];
    return cellTitle;
}

- (void)editEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view {
    [self.editEncounterBehavior doEdit:simpleAnnontation.encounter
                               forTour:self.tourCreatorBehavior.tour.uid
                           andLocation:self.encounterLocation];
}

- (void)displayPoiDetails:(MKAnnotationView *)view {
    KPAnnotation *kpAnnotation = (KPAnnotation *)view.annotation;
    __block OTCustomAnnotation *annotation = nil;
    [[kpAnnotation annotations] enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[OTCustomAnnotation class]]) {
            annotation = obj;
            *stop = YES;
        }
    }];
    if (annotation == nil) return;
    [OTLogger logEvent:@"POIView"];
    [self performSegueWithIdentifier:@"OTGuideDetailsSegue" sender:annotation.poi];
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
    }
}

- (void)entourageCreated:(NSNotification *)notification {
    if(self.currentFilter.isPro) {
        self.currentFilter.showDemand = YES;
        self.currentFilter.showContribution = YES;
        [NSUserDefaults standardUserDefaults].savedNewsfeedsFilter = [OTSavedFilter fromNewsFeedsFilter:self.currentFilter];
        [self reloadFeeds];
    }
}

- (void)clearMap {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:[self.mapView overlays]];
    [self.toggleCollectionView toggle:NO animated:NO];
}

#pragma mark - OTNewsFeedsSourceDelegate

- (void)itemsRemoved {
    [self.tableView updateItems:self.newsFeedsSourceBehavior.feedItems];
    [self feedMapWithFeedItems];
}

- (void)itemsUpdated {
    if(self.guideMapDelegate.isActive)
        return;
    self.wasLoadedOnce = YES;
    if (self.newsFeedsSourceBehavior.feedItems.count && self.isFirstLoad) {
        self.isFirstLoad = NO;
        [self showToursList];
    }
    [self.tableView updateItems:self.newsFeedsSourceBehavior.feedItems];
    [self feedMapWithFeedItems];
    if(self.toursMapDelegate.isActive) {
        if(!self.isTourListDisplayed && self.newsFeedsSourceBehavior.feedItems.count == 0)
            [self.noDataBehavior showNoData];
        else
            [self.noDataBehavior hideNoData];
    }
}

- (void)errorLoadingFeedItems:(NSError *)error {
    if(error.code == NSURLErrorNotConnectedToInternet)
        [self.tableView setNoConnection];
    else
        [self.tableView setNoFeeds];
    [self.tableView updateItems:self.newsFeedsSourceBehavior.feedItems];
    [self feedMapWithFeedItems];
}

- (void)errorLoadingNewFeedItems:(NSError *)error {
    if(error.code == NSURLErrorNotConnectedToInternet)
        [self.tableView setNoConnection];
    else
        [self.tableView setNoFeeds];
    [self registerObserver];
}

#pragma mark - OTTourCreatorBehaviorDelegate

- (void)tourStarted {
    [self.newsFeedsSourceBehavior.feedItems insertObject:self.tourCreatorBehavior.tour atIndex:0];
    [self.tableView reloadData];
    self.stopButton.hidden = NO;
    [[NSUserDefaults standardUserDefaults] setCurrentOngoingTour:self.tourCreatorBehavior.tour];
    self.createEncounterButton.hidden = NO;
    NSString *snapshotStartFilename = [NSString stringWithFormat:@SNAPSHOT_START, self.tourCreatorBehavior.tour.uid.intValue];
    [self.mapView takeSnapshotToFile:snapshotStartFilename];
    [self showNewTourOnGoing];
    [OTOngoingTourService sharedInstance].isOngoing = YES;
    self.launcherButton.enabled = YES;
}

- (void)failedToStartTour {
    self.launcherButton.enabled = YES;
}

- (void)tourDataUpdated {
    [self.overlayFeeder updateOverlayFor:self.tourCreatorBehavior.tour];
}

- (void)stoppedTour {
    self.launcherButton.hidden = YES;
    self.createEncounterButton.hidden = YES;
    [self showToursList];
    NSString *snapshotEndFilename = [NSString stringWithFormat:@SNAPSHOT_STOP, self.tourCreatorBehavior.tour.uid.intValue];
    [self.mapView takeSnapshotToFile:snapshotEndFilename];
    [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:self];
}

- (void)failedToStopTour {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:OTLocalizedString(@"failed_send_tour_points_to_server") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - FEED ITEMS

- (IBAction)doShowLaunchingOptions:(UIButton *)sender {
    NSString *eventName = @"PlusOnTourClick";
    if(![OTOngoingTourService sharedInstance].isOngoing)
        eventName = self.toursMapDelegate.isActive ? @"PlusFromFeedClick" : @"PlusFromGDSClick";
    [OTLogger logEvent:eventName];
    if(!IS_PRO_USER && !self.guideMapDelegate.isActive)
        [self performSegueWithIdentifier:@"EntourageEditor" sender:self];
    else
        [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
//    else
//        [self performSegueWithIdentifier:@"EntourageEditor" sender:self];
}

#pragma mark - OTTourCreatorDelegate

- (void)createTour:(NSString*)tourType {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self zoomToCurrentLocation:nil];
    self.launcherButton.enabled = NO;
    [self.tourCreatorBehavior startTour:tourType];
}

- (IBAction)stopTour:(id)sender {
    [OTLogger logEvent:@"SuspendTourClick"];
    [self.tourCreatorBehavior stopTour];
}

#pragma mark - OTConfirmationViewControllerDelegate

- (void)tourSent:(OTTour*)tour {
    if (self.tourCreatorBehavior.tour == nil)
        return;
    if (tour != nil && tour.uid != nil)
        if (self.tourCreatorBehavior.tour.uid == nil || ![tour.uid isEqualToNumber:self.tourCreatorBehavior.tour.uid])
            return;
    [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"tour_status_completed")];
    self.tourCreatorBehavior.tour = nil;
    [self.encounters removeAllObjects];
    self.launcherButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.createEncounterButton.hidden = YES;
    [OTOngoingTourService sharedInstance].isOngoing = NO;
    [self.tourCreatorBehavior endOngoing];
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
            [OTLogger logEvent:@"MapClick"];
            [self showToursMap];
        }
        else {
            if([self.tapEntourage hasTappedEntourage:sender].count > 0) {
                [OTLogger logEvent:@"HeatzoneMapClick"];
                [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.tapEntourage.tappedEntourage.coordinate, MAPVIEW_CLICK_REGION_SPAN_X_METERS, MAPVIEW_CLICK_REGION_SPAN_Y_METERS) animated:YES];
                if(!self.guideMapDelegate.isActive) {
                    [self loadHeatzonesWithItems:[self.tapEntourage hasTappedEntourage:sender]];
                }
            }
            else {
                [self.toggleCollectionView toggle:NO animated:YES];
            }
        }
    }
}

#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover {
    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark - OTOptionsDelegate

- (void)createTour {
    void(^createBlock)() = ^() {
        [self switchToNewsfeed];
        [self performSegueWithIdentifier:@"TourCreatorSegue" sender:nil];
    };
    if([self.presentedViewController isKindOfClass:[OTMapOptionsViewController class]])
        [self dismissViewControllerAnimated:YES completion:createBlock];
    else
        createBlock();
}

- (void)createEncounter {
    [self dismissViewControllerAnimated:NO completion:^{
        [self switchToNewsfeed];
        [self.editEncounterBehavior doEdit:nil
                                   forTour:self.tourCreatorBehavior.tour.uid
                               andLocation:self.encounterLocation];
    }];
}

- (void)createAction {
    [self createEntouragewithAlertMessage:OTLocalizedString(@"poi_create_contribution_alert")];
}

- (void) createEntouragewithAlertMessage:(NSString *)message {
    [self dismissViewControllerAnimated:NO completion:^{
        [self switchToNewsfeed];
        [self performSegueWithIdentifier:@"EntourageEditor" sender:nil];
    }];
}

- (void)togglePOI {
    NSString *message = @"";
    if([OTOngoingTourService sharedInstance].isOngoing)
        message = self.toursMapDelegate.isActive ? @"OnTourShowGuide" : @"OnTourHideGuide";
    else
        message = self.toursMapDelegate.isActive ? @"GDSViewClick" : @"MaskGDSClick";
    [OTLogger logEvent:message];
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.toursMapDelegate.isActive)
            [self switchToGuide];
        else
            [self switchToNewsfeed];
    }];
}

- (void)dismissOptions {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)proposeStructure {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PROPOSE_STRUCTURE_URL]];
}

#pragma mark - OTWebViewDelegate

- (void)webview:(NSString *)url {
    self.webview = url;
    [self.parentViewController.view.subviews.lastObject removeFromSuperview];
    if (self.webview) {
        [self performSegueWithIdentifier:@"OTWebViewSegue" sender:self];
    }
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
    [NSUserDefaults standardUserDefaults].savedNewsfeedsFilter = [OTSavedFilter fromNewsFeedsFilter:self.currentFilter];
    [self reloadFeeds];
}

#pragma mark - OTSolidarityGuideFilterDelegate

- (void)solidarityFilterChanged:(OTSolidarityGuideFilter *)filter {
    self.solidarityFilter = filter;
    [self reloadPois];
}

#pragma mark - Actions

- (void)zoomToCurrentLocation:(id)sender {
    CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
    if (currentLocation) {
        CLLocationDistance distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.mapView.centerCoordinate), MKMapPointForCoordinate(currentLocation.coordinate));
        BOOL animatedSetCenter = (distance < MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS);
        [self.mapView setCenterCoordinate:currentLocation.coordinate animated:animatedSetCenter];
        if(self.toursMapDelegate.isActive && !self.isRegionSetted) {
            self.isRegionSetted = YES;
            [self reloadFeeds];
        }
    }
}

- (IBAction)doShowNewFeedItems:(UIButton*)sender {
    self.nouveauxFeedItemsButton.hidden = YES;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

- (void)pushReceived {
    self.navigationItem.rightBarButtonItem.badgeValue = [OTUnreadMessagesService sharedInstance].totalCount.stringValue;
}

#pragma mark - Feeds Table View Delegate

- (void)loadMoreData {
    [OTLogger logEvent:@"ScrollListPage"];
    [self.newsFeedsSourceBehavior loadMoreItems];
}

- (void)showFeedInfo:(OTFeedItem *)feedItem {
    self.selectedFeedItem = feedItem;
    if([[[OTFeedItemFactory createFor:feedItem] getStateInfo] isPublic]) {
        [OTLogger logEvent:@"OpenEntouragePublicPage"];
        [self performSegueWithIdentifier:@"PublicFeedItemDetailsSegue" sender:self];
    }
    else {
        [OTLogger logEvent:@"OpenEntourageActivePage"];
        [self performSegueWithIdentifier:@"ActiveFeedItemDetailsSegue" sender:self];
    }
}

- (void)showPoiDetails:(OTPoi *)poi {
    [self performSegueWithIdentifier:@"OTGuideDetailsSegue" sender:poi];
}

- (void)showAnnouncementDetails:(OTAnnouncement *)feedItem {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:feedItem.url]];
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
            [OTLogger logEvent:@"OpenEnterInContact"];
            [self sendJoinRequest:feedItem];
            break;
        case FeedItemStateJoinPending:
            [OTLogger logEvent:@"PendingRequestOverlay"];
            [self.statusChangedBehavior configureWith:feedItem];
            [self.statusChangedBehavior startChangeStatus];
            break;
        case FeedItemStateOngoing:
            self.tourCreatorBehavior.tour = (OTTour *)feedItem;
            [OTOngoingTourService sharedInstance].isOngoing = YES;
            [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:nil];
            break;
        case FeedItemStateJoinAccepted:
        case FeedItemStateOpen:
        case FeedItemStateClosed:
            [OTLogger logEvent:@"OpenActiveCloseOverlay"];
            [self.statusChangedBehavior configureWith:feedItem];
            [self.statusChangedBehavior startChangeStatus];
            break;
        default:
            break;
    }
}

#pragma mark - Segmented control

- (IBAction)segmentChanged {
    if (self.customSegmentedBehavior.selectedIndex == 1) {
        [OTLogger logEvent:@"ListViewClick"];
        [self showToursList];
    }
    else {
        [OTLogger logEvent:@"MapViewClick"];
        [self showToursMap];
    }
}

#pragma mark - Geo and filter buttons

- (IBAction)showFilters {
    [OTLogger logEvent:@"FeedFiltersPress"];
    if (self.guideMapDelegate.isActive)
        [self performSegueWithIdentifier:@"SolidarityGuideSegue" sender:self];
    else
        [self performSegueWithIdentifier:@"FiltersSegue" sender:self];
}

- (IBAction)showCurrentLocation {
    [OTLogger logEvent:@"RecenterMapClick"];
    if(![OTLocationManager sharedInstance].isAuthorized)
        [[OTLocationManager sharedInstance] showGeoLocationNotAllowedMessage:OTLocalizedString(@"ask_permission_location_recenter_map")];
    else if(![OTLocationManager sharedInstance].currentLocation)
        [[OTLocationManager sharedInstance] showLocationNotFoundMessage:OTLocalizedString(@"no_location_recenter_map")];
    else
        [self zoomToCurrentLocation:self];
}

#pragma mark - "Screens"

- (void)showToursList {
    [OTLogger logEvent:@"Screen06_1FeedView"];
    [self.toggleCollectionView toggle:NO animated:NO];
    self.showSolidarityGuideView.hidden = YES;
    [self.noDataBehavior hideNoData];
    [self.guideInfoBehavior hide];
    self.isTourListDisplayed = YES;
    self.customSegmentedBehavior.selectedIndex = 1;
    [UIView animateWithDuration:0.2 animations:^(void) {
        CGRect mapFrame = self.mapView.frame;
        mapFrame.size.height = MAPVIEW_HEIGHT;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }];
}

- (void)showToursMap {
    if(self.guideMapDelegate.isActive) {
        [self.showSolidarityGuideView setHidden:YES];
        [self.toggleCollectionView toggle:NO animated:NO];
    }else {
        [OTLogger logEvent:@"Screen06_2MapView"];
        [self.showSolidarityGuideView setHidden:NO];
    }
    if(self.wasLoadedOnce && self.newsFeedsSourceBehavior.feedItems.count == 0)
        [self.noDataBehavior showNoData];
    self.nouveauxFeedItemsButton.hidden = YES;
    if (self.toursMapDelegate.isActive)
        self.isTourListDisplayed = NO;
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height;
    self.customSegmentedBehavior.selectedIndex = 0;
    [OTLogger logEvent:@"MapViewClick"];
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        
        MKCoordinateRegion region;
        region = MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, MAPVIEW_CLICK_REGION_SPAN_X_METERS, MAPVIEW_CLICK_REGION_SPAN_Y_METERS );
        [self.mapView setRegion:region animated:YES];
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }];
}

#pragma mark 15.2 New Tour - on going

- (void)showNewTourOnGoing {
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height;
    self.customSegmentedBehavior.selectedIndex = 0;
    self.isTourListDisplayed = NO;
    [OTLogger logEvent:@"MapViewClick"];
    [UIView animateWithDuration:0.5 animations:^(void) {
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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.joinBehavior prepareSegueForMessage:segue])
        return;
    if([self.editEntourgeBehavior prepareSegue:segue])
        return;
    if([self.editEncounterBehavior prepareSegue:segue]) {
        encounterFromTap = NO;
        return;
    }
    if([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
    UIViewController *destinationViewController = segue.destinationViewController;
    if([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTUserViewController *controller = (OTUserViewController*)navController.topViewController;
        controller.user = (OTUser*)sender;
    }
    else if([segue.identifier isEqualToString:@"OTConfirmationPopup"]) {
        OTConfirmationViewController *controller = (OTConfirmationViewController *)destinationViewController;
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.view.backgroundColor = [UIColor appModalBackgroundColor];
        controller.delegate = self;
        [OTOngoingTourService sharedInstance].isOngoing = NO;
        [controller configureWithTour:self.tourCreatorBehavior.tour andEncountersCount:[NSNumber numberWithUnsignedInteger:[self.encounters count]]];
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
        else
            self.tappedLocation = nil;
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
    else if([segue.identifier isEqualToString:@"OTGuideDetailsSegue"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTGuideDetailsViewController *controller = navController.childViewControllers[0];
        controller.poi = (OTPoi *)sender;
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
        CLLocation *currentLocation = self.tappedLocation ? self.tappedLocation : [OTLocationManager sharedInstance].currentLocation;
        controller.location = currentLocation;
        controller.entourageEditorDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"FiltersSegue"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTFeedItemFiltersViewController *controller = (OTFeedItemFiltersViewController*)navController.topViewController;
        controller.filterDelegate = self;
    }
    else if ([segue.identifier isEqualToString:@"SolidarityGuideSegue"]) {
        UINavigationController *navController = (UINavigationController *)destinationViewController;
        OTSolidarityGuideFiltersViewController *controller = (OTSolidarityGuideFiltersViewController *)navController.topViewController;
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
    else if ([segue.identifier isEqualToString:@"OTWebViewSegue"]) {
        OTWebViewController *controller = (OTWebViewController *)destinationViewController;
        controller.urlString = self.webview;
        [self showToursList];
        UIView *grayView = [[UIView alloc] initWithFrame:self.parentViewController.view.frame];
        grayView.backgroundColor = [UIColor appGreyishColor];
        grayView.alpha = 0.6;
        [self.parentViewController.view addSubview:grayView];
        controller.webViewDelegate = self;
    }
}

- (void)sendCloseMail: (NSNotification *)notification {
    OTCloseReason reason = [[notification.userInfo objectForKey:@kNotificationSendReasonKey] intValue];
    OTEntourage *feedItem = [notification.userInfo objectForKey:@kNotificationFeedItemKey];
    [self.mailSender sendCloseMail:reason forItem: feedItem];
}

- (void)updateBadge {
    self.navigationItem.rightBarButtonItem.badgeValue = [OTUnreadMessagesService sharedInstance].totalCount.stringValue;
    [self forceGetNewData];
}

- (void)encounterEdited: (NSNotification *)notification {
    OTEncounter *encounter = [notification readEncounter];
    [self updateEncounter:encounter];
}

- (void)updateEncounter: (OTEncounter *)encounter {
    if(self.encounters.count == 0) {
        [self.encounters addObject: encounter];
    } else {
        int i=0;
        for(OTEncounter *meeting in self.encounters) {
            if([meeting.sid isEqualToNumber: encounter.sid]) {
                [self.encounters replaceObjectAtIndex:i withObject:encounter];
                break;
            }
            i++;
        }
        if(self.encounters.count == i)
            [self.encounters addObject: encounter];
    }
    [self feedMapViewWithEncounters];
}

- (IBAction)encounterChanged {
    [self updateEncounter: self.editEncounterBehavior.encounter];
}

- (void)entourageUpdated:(NSNotification *)notification {
    [self.newsFeedsSourceBehavior.feedItems removeAllObjects];
    [self.newsFeedsSourceBehavior getNewItems];
    [self reloadFeeds];
    [self feedMapWithFeedItems];
}

- (IBAction)showGuide {
    [OTLogger logEvent:@"SolidarityGuideFrom06Map"];
    [self switchToGuide];
}

- (void)associationUpdated {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if(currentUser.partner == nil) {
        self.currentFilter.showFromOrganisation = NO;
        [NSUserDefaults standardUserDefaults].savedNewsfeedsFilter = [OTSavedFilter fromNewsFeedsFilter:self.currentFilter];
    }
    [self reloadFeeds];
}
    
@end
