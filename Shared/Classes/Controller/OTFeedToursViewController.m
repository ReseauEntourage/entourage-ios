//
//  OTFeedToursViewController.m
//  entourage
//
//  Created by Jr on 17/02/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

#import "OTFeedToursViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>

#import "OTTourOptionsViewController.h"
#import "OTQuitFeedItemViewController.h"
#import "OTTourCreatorViewController.h"
#import "OTFeedItemFiltersViewController.h"
#import "OTPublicFeedItemViewController.h"
#import "OTToursMapDelegate.h"
#import "OTEncounterAnnotation.h"
#import "OTTourService.h"
#import "MKMapView+entourage.h"
#import "OTOverlayFeederBehavior.h"
#import "OTTapEntourageBehavior.h"
#import "OTNewsFeedsFilter.h"
#import "OTNewsFeedsSourceDelegate.h"
#import "OTNewsFeedsSourceBehavior.h"
#import "OTTourCreatorBehavior.h"
#import "OTTourCreatorBehaviorDelegate.h"
#import "OTStartTourAnnotation.h"
#import "OTSavedFilter.h"
#import "OTEditEncounterBehavior.h"
#import "OTToggleVisibleBehavior.h"
#import "entourage-Swift.h"
#import "OTNeighborhoodAnnotation.h"
#import "OTPrivateCircleAnnotation.h"
#import "OTOutingAnnotation.h"

#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define FEEDS_REQUEST_DISTANCE_KM 10

#define LONGPRESS_DELTA 65.0f

@interface OTFeedToursViewController ()
<
UIGestureRecognizerDelegate,
UIScrollViewDelegate,
OTFeedItemsTableViewDelegate,
OTTourCreatorDelegate,
OTFeedItemQuitDelegate,
OTFeedItemsFilterDelegate,
OTNewsFeedsSourceDelegate,
OTTourCreatorBehaviorDelegate
>

@property (nonatomic, weak) IBOutlet OTFeedItemsTableView           *tableView;
@property (nonatomic, weak) IBOutlet OTMapDelegateProxyBehavior     *mapDelegateProxy;
@property (nonatomic, weak) IBOutlet OTOverlayFeederBehavior        *overlayFeeder;
@property (nonatomic, weak) IBOutlet OTTapEntourageBehavior         *tapEntourage;
@property (nonatomic, weak) IBOutlet OTJoinBehavior                 *joinBehavior;
@property (nonatomic, weak) IBOutlet OTStatusChangedBehavior        *statusChangedBehavior;
@property (nonatomic, weak) IBOutlet OTEditEncounterBehavior        *editEncounterBehavior;
@property (nonatomic, weak) IBOutlet OTNewsFeedsSourceBehavior      *newsFeedsSourceBehavior;
@property (nonatomic, weak) IBOutlet OTTourCreatorBehavior          *tourCreatorBehavior;
@property (nonatomic, strong) OTMapView                             *mapView;
@property (nonatomic, strong) UITapGestureRecognizer                *tapGestureRecognizer;
@property (nonatomic) CLLocationCoordinate2D                        encounterLocation;
@property (nonatomic, strong) OTToursMapDelegate                    *toursMapDelegate;
@property (nonatomic, strong) NSString                              *entourageType;
@property (nonatomic, strong) NSMutableArray                        *encounters;
@property (nonatomic) BOOL                                          isRegionSetted;
@property (nonatomic, assign) CGPoint                               mapPoint;
@property (nonatomic, strong) CLLocation                            *tappedLocation;
@property (nonatomic) BOOL                                          isTourListDisplayed;
@property (nonatomic, weak) IBOutlet UIButton                       *launcherButton;
@property (nonatomic, weak) IBOutlet UIButton                       *stopButton;

@property (nonatomic, weak) IBOutlet UIButton                       *nouveauxFeedItemsButton;
@property (nonatomic, strong) OTNewsFeedsFilter                     *currentFilter;
@property (nonatomic) BOOL                                          isFirstLoad;
@property (nonatomic) BOOL                                          wasLoadedOnce;
@property (nonatomic) BOOL                                          noDataDisplayed;
@property (nonatomic) BOOL                                          inviteBehaviorTriggered;
@property (nonatomic) BOOL                                          addEditEvent;
@property (nonatomic, weak) IBOutlet OTNoDataBehavior               *noDataBehavior;
@property (nonatomic, weak) IBOutlet OTMailSenderBehavior           *mailSender;
@property (nonatomic, strong) IBOutlet OTToggleVisibleBehavior      *toggleCollectionView;
@property (nonatomic, strong) IBOutlet UIView  *hideScreenPlaceholder;
@property (nonatomic, strong) IBOutlet UILabel  *hideScreenPlaceholderTitle;
@property (nonatomic, strong) IBOutlet UILabel  *hideScreenPlaceholderSubtitle;

//New buttons
@property (weak, nonatomic) IBOutlet UIButton *ui_button_filters;
@property (weak, nonatomic) IBOutlet UIButton *ui_button_map_list;

@property (nonatomic) BOOL isEventMenuSelected, isEncounterSelected;
@property (nonatomic, strong) OTNewsFeedsFilter *encounterFilter;

@property (nonatomic) BOOL encounterFromTap;
@property (nonatomic) BOOL forceReloadingFeeds;

@end

@implementation OTFeedToursViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
    [self configureActionsButton];
    
    self.isEncounterSelected = YES;
    
    [self changeViewMenuState];
    
}

- (void)configureActionsButton {
    [self.launcherButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.launcherButton.layer setShadowOpacity:0.5];
    [self.launcherButton.layer setShadowRadius:4.0];
    self.launcherButton.layer.masksToBounds = NO;
    [self.launcherButton.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    self.launcherButton.layer.cornerRadius = 29;
    
    self.launcherButton.hidden = YES;
    
    if (![OTAppConfiguration supportsAddingActionsFromMap]) {
        self.launcherButton.hidden = YES;
    }
    
    [self.ui_button_filters.layer setCornerRadius:self.ui_button_filters.frame.size.height / 2];
    [self.ui_button_map_list.layer setCornerRadius:self.ui_button_map_list.frame.size.height / 2];
    
    [self.ui_button_filters.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.ui_button_filters.layer setShadowOpacity:0.5];
    [self.ui_button_filters.layer setShadowRadius:4.0];
    [self.ui_button_filters.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    
    [self.ui_button_map_list.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.ui_button_map_list.layer setShadowOpacity:0.5];
    [self.ui_button_map_list.layer setShadowRadius:4.0];
    [self.ui_button_map_list.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
}

- (void)setup {
    self.isFirstLoad = YES;
    [self.toggleCollectionView initialize];
    [self.toggleCollectionView toggle:NO animated:NO];
    
    [self.noDataBehavior initialize];
    [self.newsFeedsSourceBehavior initialize];
    
    self.newsFeedsSourceBehavior.delegate = self;
    self.newsFeedsSourceBehavior.tableDelegate = self.tableView;
    
    self.currentFilter = [OTNewsFeedsFilter new];
    self.encounters = [NSMutableArray new];
    self.mapView = [OTMapView new];
    self.mapDelegateProxy.mapView = self.mapView;
    self.overlayFeeder.mapView = self.mapView;
    [self.mapDelegateProxy initialize];
    self.tapEntourage.mapView = self.mapView;
    
    self.toursMapDelegate = [[OTToursMapDelegate alloc] initWithMapController:self];
    [self.tableView configureWithMapView:self.mapView];
    self.tableView.feedItemsDelegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 140;
    [self configureMapView];
    
    if (OTSharedOngoingTour.isOngoing ||
        [NSUserDefaults standardUserDefaults].currentOngoingTour != nil) {
        [self setupUIForTourOngoing];
    } else {
        [self showToursMap];
        [self clearMap];
        self.launcherButton.hidden = NO;
        self.stopButton.hidden = YES;
    }
    
    //[self switchToNewsfeed];
    [self.tableView showEncountersOnlyAction];
    [self reloadFeeds];
    
    [self.mapDelegateProxy.delegates addObject:self];
    [self addObservers];
    
    [self showToursListAction];
}

-(void) changeFilterButton {
    if (self.encounterFilter == nil) {
        self.encounterFilter = [OTNewsFeedsFilter new];
        self.encounterFilter.isPro = YES;
        [self.encounterFilter changeFiltersForProOnly];
    }
    
    if ([self.encounterFilter isDefaultEncounterFilters]) {
        [self.ui_button_filters setTitle:OTLocalizedString(@"home_button_filters").uppercaseString forState:UIControlStateNormal];
    }
    else {
        [self.ui_button_filters setTitle:OTLocalizedString(@"home_button_filters_on").uppercaseString forState:UIControlStateNormal];
    }
}

- (void)setupUIForTourOngoing {
    
    [self.tourCreatorBehavior initialize];
    self.tourCreatorBehavior.delegate = self;
    [self showNewTourOnGoing];
    [self clearMap];
    self.tourCreatorBehavior.tour = [NSUserDefaults standardUserDefaults].currentOngoingTour;
    self.launcherButton.hidden = YES;
    self.stopButton.hidden = NO;
    
    [[OTTourService new] tourEncounters:self.tourCreatorBehavior.tour
                                success:^(NSArray *items) {
        self.encounters = [NSMutableArray arrayWithArray:items];
    } failure:^(NSError *error) {
        NSLog(@"GET TOUR ENCOUNTERSErr: %@", error.description);
    }];
    [self feedMapViewWithEncounters];
}

- (void)checkIfShouldDisableFeedsAndMap {
    if (![OTAppConfiguration shouldHideFeedsAndMap]) {
        return;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.hideScreenPlaceholder.hidden = NO;
    self.hideScreenPlaceholder.backgroundColor = [[ApplicationTheme shared] tableViewBackgroundColor];
    [self.view bringSubviewToFront:self.hideScreenPlaceholder];
    
    self.hideScreenPlaceholderTitle.textColor = [[ApplicationTheme shared] titleLabelColor];
    self.hideScreenPlaceholderSubtitle.textColor = [[ApplicationTheme shared] subtitleLabelColor];
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
                                             selector:@selector(showCurrentLocation)
                                                 name:@kNotificationShowFeedsMapCurrentLocation
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationUpdated:)
                                                 name:kNotificationLocationUpdated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(forceGetNewData)
                                                 name:@kNotificationReloadData
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendCloseMail:)
                                                 name:@kNotificationSendCloseMail
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [OTAppConfiguration updateAppearanceForMainTabBar];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self.newsFeedsSourceBehavior resume];
    
    [self setupNavBar:animated];
}


-(void) setupNavBar:(BOOL)animated {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navBarAppear = [UINavigationBarAppearance new];
        
        [navBarAppear configureWithOpaqueBackground];
        [navBarAppear setBackgroundColor:[UIColor whiteColor]];
        [navBarAppear setTitleTextAttributes:@{@"foregroundColor":[UIColor appOrangeColor]}];
        navBar.standardAppearance = navBarAppear;
        navBar.scrollEdgeAppearance = navBarAppear;
    } else {
        [navBar setBackgroundColor:[UIColor whiteColor]];
        [navBar setTintColor:[UIColor appOrangeColor]];
        [navBar setBarTintColor:[UIColor whiteColor]];
        [navBar setTitleTextAttributes:@{@"foregroundColor":[UIColor appOrangeColor]}];
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    self.title = @"Maraudes";
    
    UIButton * btnLeft = [UIButton new];
    [btnLeft setImage:[UIImage imageNamed:@"backItem"] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    btnLeft.frame = CGRectMake(0, 0, 34/2, 28/2);
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btnLeft];
    [self.navigationItem setLeftBarButtonItem:item];
}

-(void) onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.newsFeedsSourceBehavior pause];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTAppState hideTabBar:NO];
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
    
    if (self.webview) {
        [self performSegueWithIdentifier:@"OTWebViewSegue" sender:self];
    }
    
    [self configureNavigationBar];
    [self checkIfShouldDisableFeedsAndMap];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.toursMapDelegate.isActive) {
        [self reloadFeeds];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObserver:self
                                               forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")];
}

- (IBAction)dismissFeedItemJoinRequestController {
    [self.tableView reloadData];
}

- (void)switchToNewsfeed {
    [OTLogger logEvent:@"Screen06_1FeedView"];
    [self.tableView switchToFeeds];
   // [self.tableView showEncountersOnlyAction];
    [self.tableView updateItems:self.newsFeedsSourceBehavior.feedItems];
    [self.noDataBehavior switchedToNewsfeeds];
    self.toursMapDelegate.isActive = YES;
    
    if (self.toursMapDelegate) {
        [self.mapDelegateProxy.delegates addObject:self.toursMapDelegate];
    }
    
    [self clearMap];
    [self feedMapWithFeedItems];
    
    [self showFeedsList];
    [self configureNavigationBar];
}

#pragma mark - Methods called from nav bar (button +)

- (void) showProposeFromNav {
    self.addEditEvent = NO;
    [self dismissViewControllerAnimated:false completion:nil];
    
    NSString *url = [NSString stringWithFormat: PROPOSE_STRUCTURE_URL, [OTHTTPRequestManager sharedInstance].baseURL, TOKEN];
    [OTSafariService launchInAppBrowserWithUrlString:url viewController:self.navigationController];
}

- (void) createTourFromNav {
    
    void(^createBlock)(void) = ^() {
        [self switchToNewsfeed];
        [self performSegueWithIdentifier:@"TourCreatorSegue" sender:nil];
    };
    
    if ([self.presentedViewController isKindOfClass:[OTMapOptionsViewController class]])
        [self dismissViewControllerAnimated:YES completion:createBlock];
    else
        createBlock();
}

- (void) createEncounterFromNav {
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self switchToNewsfeed];
        [self.editEncounterBehavior doEdit:nil
                                   forTour:self.tourCreatorBehavior.tour.uid
                               andLocation:self.encounterLocation];
    }];
}

#pragma mark - IBActions Top bar + Menu

- (IBAction)action_show_encounters:(id)sender {
    [self.tableView showEncountersOnlyAction];
    self.isEncounterSelected = YES;
    [self changeViewMenuState];
}
- (IBAction)action_filters:(id)sender {
    [self showFilters];
}
- (IBAction)action_map_list:(id)sender {
    [self rightBarButtonAction];
}

-(void)changeViewMenuState {
//    if (self.isFirstLoad) {
//        self.isEventMenuSelected = NO;
//        self.isEncounterSelected = NO;
//    }
    
    if (self.isEncounterSelected) {
        [self.ui_button_filters setHidden: NO];
    }
    else {
        if (self.isEventMenuSelected) {
            [self.ui_button_filters setHidden: YES];
        }
        else {
            [self.ui_button_filters setHidden: NO];
        }
    }
    
    [self changeFilterButton];
    
    
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
    self.mapView.showsBuildings = NO;
    self.mapView.showsTraffic = NO;
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    CLLocationCoordinate2D mapCenter;
    
    if(currentUser.hasActionZoneDefined)
        mapCenter = currentUser.addressPrimary.location.coordinate;
    else if([OTLocationManager sharedInstance].currentLocation)
        mapCenter = [OTLocationManager sharedInstance].currentLocation.coordinate;
    else
        mapCenter = CLLocationCoordinate2DMake(PARIS_LAT, PARIS_LON);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapCenter, MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
    
    [self.mapView setRegion:region animated:NO];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.mapView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)configureNavigationBar {
    [self changeFilterButton];
    
    [self.ui_button_map_list setTitle:[self rightBarButtonTitle] forState:UIControlStateNormal];
}

- (void)rightBarButtonAction
{
    if (self.isTourListDisplayed) {
        [self showToursMapAction];
    } else {
        [self showToursListAction];
    }
    
    [self configureNavigationBar];
}

- (NSString*)rightBarButtonTitle
{
    if (self.isTourListDisplayed) {
        return OTLocalizedString(@"home_button_map").uppercaseString;
    } else {
        return OTLocalizedString(@"home_button_list").uppercaseString;
    }
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
    
    if (![OTAppConfiguration supportsAddingActionsFromMapOnLongPress]) {
        return;
    }
    
    if (self.isTourListDisplayed) {
        return;
    }
    
    if (!IS_PRO_USER) {
        if ([NSUserDefaults standardUserDefaults].currentUser.isAnonymous) {
            return;
        }
        
        [self performSegueWithIdentifier:@"EntourageEditor" sender:nil];
        return;
    }
    
    CGPoint touchPoint = [longPressGesture locationInView:self.mapView];
    if (self.presentedViewController) {
        return;
    }
    
    self.mapPoint = touchPoint;
    CLLocationCoordinate2D whereTap = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    self.tappedLocation = [[CLLocation alloc] initWithLatitude:whereTap.latitude longitude:whereTap.longitude];
    
    if ([OTOngoingTourService sharedInstance].isOngoing) {
        self.encounterFromTap = YES;
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
        
        [self createQuickEncounter];
        
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
        
        if ([OTAppConfiguration supportsAddingActionsFromMap]) {
            [self performSegueWithIdentifier:@"OTMapOptionsSegue" sender:nil];
        }
    }
}

- (void)appWillEnterBackground:(NSNotification*)note {
    [self.newsFeedsSourceBehavior pause];
    
    if ([OTOngoingTourService sharedInstance].isOngoing) {
        [self createLocalNotificationForTour: self.tourCreatorBehavior.tour.uid];
    }
}

- (void)createQuickEncounter {
    
    // EMA-2138
    //[self performSegueWithIdentifier:@"OTTourOptionsSegue" sender:nil];
    
    [self switchToNewsfeed];
    [self.editEncounterBehavior doEdit:nil
                               forTour:self.tourCreatorBehavior.tour.uid
                           andLocation:self.encounterLocation];
}

- (void)registerObserver {
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"") options:NSKeyValueObservingOptionNew context:nil];
}

- (void)reloadFeeds {
    [self.tableView loadBegun];
    if (self.newsFeedsSourceBehavior.showEncountersOnly) {
        if (self.encounterFilter == nil) {
            self.encounterFilter = [OTNewsFeedsFilter new];
            self.encounterFilter.isPro = YES;
            [self.encounterFilter changeFiltersForProOnly];
        }
        
        [self.newsFeedsSourceBehavior reloadItemsAt:self.mapView.centerCoordinate withFilters:self.encounterFilter forceReload:YES];
    }
    else if (self.newsFeedsSourceBehavior.showEventsOnly) {
        [self.newsFeedsSourceBehavior loadEventsAt:self.mapView.centerCoordinate];
    }
    else {
        [self.newsFeedsSourceBehavior reloadItemsAt:self.mapView.centerCoordinate withFilters:self.currentFilter forceReload:self.forceReloadingFeeds];
    }
    [self.toggleCollectionView toggle:NO animated:NO];
}

- (void)willChangePosition {
    [self.noDataBehavior hideNoData];
}

- (void)didChangePosition {
    CLLocationDistance moveDistance = (MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.newsFeedsSourceBehavior.lastOkCoordinate), MKMapPointForCoordinate(self.mapView.centerCoordinate))) / 1000.0f;
    if (self.toursMapDelegate.isActive) {
        if (moveDistance < FEEDS_REQUEST_DISTANCE_KM / 4) {
            return;
        }
        [self reloadFeeds];
    }
}

- (IBAction)forceGetNewData {
    NSLog(@"Forcing get new data.");
    [self.newsFeedsSourceBehavior getNewItems];
}

- (void)feedMapWithFeedItems {
    
    // For Entourage we display the feeds, enconters and tours only if tours map is active
    
    if (self.toursMapDelegate.isActive) {
        NSMutableArray *feedItems = [[NSMutableArray alloc] init];
        for (OTFeedItem *item in self.newsFeedsSourceBehavior.feedItems) {
            if (![item isKindOfClass:[OTAnnouncement class]]) {
                [feedItems addObject:item];
            }
        }
        
        [self.overlayFeeder updateOverlays:feedItems];
        NSMutableArray *annotations = [NSMutableArray new];
        
        for (OTEncounter *encounter in self.encounters) {
            OTEncounterAnnotation *pointAnnotation = [[OTEncounterAnnotation alloc] initWithEncounter:encounter];
            [annotations addObject:pointAnnotation];
        }
        
        for (OTFeedItem *item in self.newsFeedsSourceBehavior.feedItems) {
            if ([item isKindOfClass:[OTTour class]]) {
                OTStartTourAnnotation *startAnnotation = [[OTStartTourAnnotation alloc] initWithTour:(OTTour *)item];
                if (startAnnotation) {
                    [annotations addObject:startAnnotation];
                }
            } else {
                if ([item isKindOfClass:[OTEntourage class]]) {
                    if ([OTAppConfiguration shouldShowPOIsOnFeedsMap]) {
                        if ([item isNeighborhood]) {
                            OTNeighborhoodAnnotation *entFeedAnnotation = [[OTNeighborhoodAnnotation alloc] initWithEntourage:(OTEntourage*)item];
                            if (entFeedAnnotation) {
                                [annotations addObject:entFeedAnnotation];
                            }
                        } else if ([item isPrivateCircle]) {
                            OTPrivateCircleAnnotation *entFeedAnnotation = [[OTPrivateCircleAnnotation alloc] initWithEntourage:(OTEntourage*)item];
                            if (entFeedAnnotation) {
                                [annotations addObject:entFeedAnnotation];
                            }
                        }
                    }
                    if ([item isOuting]) {
                        OTOutingAnnotation *entFeedAnnotation = [[OTOutingAnnotation alloc] initWithEntourage:(OTEntourage*)item];
                        if (entFeedAnnotation) {
                            [annotations addObject:entFeedAnnotation];
                        }
                    }
                }
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

- (void)createLocalNotificationForTour:(NSNumber*)tourId {
    
    if (!tourId) {
        return;
    }
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    localNotification.alertBody = OTLocalizedString(@"tour_ongoing");
    localNotification.alertAction = OTLocalizedString(@"Stop");
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = @{@"tourId": tourId, @"object":OTLocalizedString(@"tour_ongoing")};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)showToursMapAction
{
    [OTLogger logEvent:Action_feed_showMap];
    
    [self showToursMap];
}

- (void)showToursListAction
{
    [OTLogger logEvent:Action_feed_showList];
    
    [self showFeedsList];
}

#pragma mark - Location updates

- (void)locationUpdated:(NSNotification *)notification {
    NSArray *locations = [notification readLocations];
    for (CLLocation *newLocation in locations) {
        if (!self.encounterFromTap)
            self.encounterLocation = newLocation.coordinate;
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
    
    self.wasLoadedOnce = YES;
    if (self.newsFeedsSourceBehavior.feedItems.count && self.isFirstLoad) {
        self.isFirstLoad = NO;
        [self showFeedsList];
    }
    
    [self.tableView updateItems:self.newsFeedsSourceBehavior.feedItems];
    [self feedMapWithFeedItems];
    
    if (self.toursMapDelegate.isActive) {
        if (!self.isTourListDisplayed && self.newsFeedsSourceBehavior.feedItems.count == 0) {
            [self.noDataBehavior showNoData];
        }
        else {
            [self.noDataBehavior hideNoData];
        }
    }
}

- (void)errorLoadingFeedItems:(NSError *)error {
    if (error.code == NSURLErrorNotConnectedToInternet)
        [self.tableView setNoConnection];
    else
        [self.tableView setNoFeeds];
    [self.tableView updateItems:self.newsFeedsSourceBehavior.feedItems];
    [self feedMapWithFeedItems];
}

- (void)errorLoadingNewFeedItems:(NSError *)error {
    if (error.code == NSURLErrorNotConnectedToInternet)
        [self.tableView setNoConnection];
    else
        [self.tableView setNoFeeds];
    [self registerObserver];
}

#pragma mark - OTTourCreatorBehaviorDelegate

- (void)tourStarted {
    [self.newsFeedsSourceBehavior addFeedItemToFront:self.tourCreatorBehavior.tour];
    self.stopButton.hidden = NO;
    [[NSUserDefaults standardUserDefaults] setCurrentOngoingTour:self.tourCreatorBehavior.tour];
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
    [self showFeedsList];
    
    NSString *snapshotEndFilename = [NSString stringWithFormat:@SNAPSHOT_STOP, self.tourCreatorBehavior.tour.uid.intValue];
    [self.mapView takeSnapshotToFile:snapshotEndFilename];
    [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:self];
}

- (void)failedToStopTour {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:OTLocalizedString(@"failed_send_tour_points_to_server") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - FEED ITEMS

- (IBAction)doShowLaunchingOptions:(UIButton *)sender {
    [OTLogger logEvent:Action_Plus_Structure];
}

#pragma mark - OTTourCreatorDelegate

- (void)createTour:(NSString*)tourType {
    [OTAppState hideTabBar:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self zoomToCurrentLocation:nil];
    self.launcherButton.enabled = NO;
    [self.tourCreatorBehavior initialize];
    self.tourCreatorBehavior.delegate = self;
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
    
    self.launcherButton.hidden = YES;
    
    self.stopButton.hidden = YES;
    
    [OTOngoingTourService sharedInstance].isOngoing = NO;
    [self.tourCreatorBehavior endOngoing];
    [self clearMap];
    [self forceGetNewData];
}

- (void)tourCloseError {
    self.launcherButton.hidden = YES;
}

- (void)resumeTour {
    [OTOngoingTourService sharedInstance].isOngoing = YES;
    self.stopButton.hidden = NO;
}

#pragma mark - UIGestureRecognizerDelegate

- (void)handleTap:(UITapGestureRecognizer *)sender {
    NSLog(@"********** HANDLE TAP *********");
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.isTourListDisplayed) {
            [OTLogger logEvent:Action_feed_showMap];
            [self showToursMapAction];
        }
        
        [self configureNavigationBar];
    }
}

#pragma mark - OTFeedItemQuitDelegate

- (void)didQuitFeedItem:(OTFeedItem *)item {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

#pragma mark - OTFeedItemsFilterDelegate

- (void)filterChanged:(OTNewsFeedsFilter *)filter {
    if (filter == nil) {
        // discard the changes if user pressed close button
        //self.currentFilter = [OTNewsFeedsFilter new];
        return;
    }
    self.forceReloadingFeeds = NO;
    if (self.isEncounterSelected) {
        self.encounterFilter = filter;
        NSLog(@"***** ici chane filter encounter : %@",self.encounterFilter.description);
    }
    else {
        self.currentFilter = filter;
        NSLog(@"***** ici chane filter : %d",self.currentFilter.showContributionOther);
        [NSUserDefaults standardUserDefaults].savedNewsfeedsFilter = [OTSavedFilter fromNewsFeedsFilter:self.currentFilter];
    }
    
    [self changeFilterButton];
    
    [self reloadFeeds];
}

#pragma mark - Actions

- (void)zoomToCurrentLocation:(id)sender {
    CLLocation *currentLocation = [OTLocationManager sharedInstance].currentLocation;
    [self zoomMapToLocation:currentLocation];
}

- (void)zoomMapToLocation:(CLLocation*)location {
    if (location) {
        CLLocationDistance distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(self.mapView.centerCoordinate), MKMapPointForCoordinate(location.coordinate));
        BOOL animatedSetCenter = (distance < MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS);
        [self.mapView setCenterCoordinate:location.coordinate animated:animatedSetCenter];
        
        if (self.toursMapDelegate.isActive && !self.isRegionSetted) {
            self.isRegionSetted = YES;
            [self reloadFeeds];
        }
    }
}

#pragma mark - Feeds Table View Delegate

- (void)loadMoreData {
    [OTLogger logEvent:@"ScrollListPage"];
    [self.newsFeedsSourceBehavior loadMoreItems];
}

- (void)showFeedInfo:(OTFeedItem *)feedItem {
    self.selectedFeedItem = feedItem;
    if ([[[OTFeedItemFactory createFor:feedItem] getStateInfo] isPublic]) {
        [self performSegueWithIdentifier:@"PublicFeedItemDetailsSegue" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"ActiveFeedItemDetailsSegue" sender:self];
    }
}

- (void)showAnnouncementDetails:(OTAnnouncement *)feedItem {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:feedItem.url]];
}

- (void)showPoiDetails:(OTPoi*)poi {}
- (void)showUserProfile:(NSNumber*)userId {
    [[OTAuthService new] getDetailsForUser:userId.stringValue success:^(OTUser *user) {
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
            self.statusChangedBehavior.shouldShowTabBarWhenFinished = YES;
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
            self.statusChangedBehavior.shouldShowTabBarWhenFinished = YES;
            [self.statusChangedBehavior startChangeStatus];
            break;
        default:
            break;
    }
}

- (void)didPanHeaderDown {
    [self showMapAnimated:NO];
}

-(void)showEncountersOnly {
    [OTLogger logEvent:Action_feed_showTours];
    self.newsFeedsSourceBehavior.showEncountersOnly = YES;
    self.forceReloadingFeeds = NO;
    [self.noDataBehavior switchedToEncounters];
    [self configureNavigationBar];
    [self reloadFeeds];
}

- (void)mapDidBecomeVisible:(BOOL)visible {
}

#pragma mark - Geo and filter buttons

- (IBAction)showFilters {
    
    [OTLogger logEvent:Action_feed_showFilters];
    
    [OTAppState showFilteringOptionsFromController:self withFullMapVisible:NO];
}

- (IBAction)showCurrentLocation {
    [OTLogger logEvent:@"RecenterMapClick"];
    
    if (![OTLocationManager sharedInstance].isAuthorized) {
        [[OTLocationManager sharedInstance] showGeoLocationNotAllowedMessage:OTLocalizedString(@"ask_permission_location_recenter_map")];
    }
    else if(![OTLocationManager sharedInstance].currentLocation) {
        [[OTLocationManager sharedInstance] showLocationNotFoundMessage:OTLocalizedString(@"no_location_recenter_map")];
    }
    else {
        [self zoomToCurrentLocation:self];
    }
}

#pragma mark - "Screens"

- (void)showFeedsList {
    self.tableView.scrollEnabled = YES;
    [self.mapView setScrollEnabled:NO];
    [OTLogger logEvent:@"Screen06_1FeedView"];
    [self.toggleCollectionView toggle:NO animated:NO];
    [self.noDataBehavior hideNoData];
    
    self.isTourListDisplayed = YES;
    
    [self.tableView setTableHeaderView:[self.tableView headerViewWithMap:self.mapView
                                                               mapHeight:MAPVIEW_HEIGHT
                                                              showFilter:[OTAppConfiguration supportsFilteringEvents]]];
    
    self.isTourListDisplayed = YES;
    [self configureNavigationBar];
}

- (void)showMapAnimated:(BOOL)animated {
    self.tableView.scrollEnabled = NO;
    self.forceReloadingFeeds = NO;
    
    [OTLogger logEvent:@"Screen06_2MapView"];
    
    if (self.wasLoadedOnce && self.newsFeedsSourceBehavior.feedItems.count == 0) {
        [self.noDataBehavior showNoData];
    }
    self.nouveauxFeedItemsButton.hidden = YES;
    
    if (self.toursMapDelegate.isActive) {
        self.isTourListDisplayed = NO;
    }
    
    [self.mapView setScrollEnabled:YES];
    
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = self.view.bounds.size.height;
    
    [OTLogger logEvent:@"MapViewClick"];
    
    NSTimeInterval duration = animated ? 0.25 : 0.0;
    [UIView animateWithDuration:duration animations:^(void) {
        MKCoordinateRegion region;
        region = MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
        [self.mapView setRegion:region animated:animated];
        [self.tableView setTableHeaderView:[self.tableView headerViewWithMap:self.mapView
                                                                   mapHeight:mapFrame.size.height
                                                                  showFilter:YES]];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:animated];
    }];
    
    [self configureNavigationBar];
}

- (void)showToursMap {
    [self showMapAnimated:NO];
}

#pragma mark 15.2 New Tour - on going

- (void)showNewTourOnGoing {
    CGRect mapFrame = self.mapView.frame;
    mapFrame.size.height = [UIScreen mainScreen].bounds.size.height;
    
    self.isTourListDisplayed = NO;
    
    [OTLogger logEvent:@"MapViewClick"];
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.launcherButton.hidden = YES;
        self.tableView.tableHeaderView.frame = mapFrame;
        self.mapView.frame = mapFrame;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
        [self.tableView updateWithMapView:self.mapView mapHeight:mapFrame.size.height showFilter:NO];
    }];
    
    [self configureNavigationBar];
}

- (void)showTourConfirmation {
    if ([OTOngoingTourService sharedInstance].isOngoing) {
        [self performSegueWithIdentifier:@"OTConfirmationPopup" sender:nil];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.joinBehavior prepareSegueForMessage:segue])
        return;
    if([self.editEncounterBehavior prepareSegue:segue]) {
        self.encounterFromTap = NO;
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
        [OTAppState hideTabBar:YES];
        controller.delegate = self;
        [OTOngoingTourService sharedInstance].isOngoing = NO;
        [controller configureWithTour:self.tourCreatorBehavior.tour andEncountersCount:[NSNumber numberWithUnsignedInteger:[self.encounters count]]];
    }
    else if([segue.identifier isEqualToString:@"FiltersSegue"]) { //*****
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTFeedItemFiltersViewController *controller = (OTFeedItemFiltersViewController*)navController.topViewController;
        controller.filterDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"OTTourOptionsSegue"]) {
        OTTourOptionsViewController *controller = (OTTourOptionsViewController *)destinationViewController;
        controller.optionsDelegate = self;
        [controller setIsPOIVisible:NO];
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
        else {
            self.tappedLocation = nil;
        }
        controller.optionsDelegate = self;
        [controller setIsPOIVisible:NO];
    }
    else if([segue.identifier isEqualToString:@"TourCreatorSegue"]) {
        [OTAppState hideTabBar:YES];
        OTTourCreatorViewController *controller = (OTTourCreatorViewController *)destinationViewController;
        controller.view.backgroundColor = [UIColor clearColor];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.tourCreatorDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"PublicFeedItemDetailsSegue"]) {
        OTPublicFeedItemViewController *controller = (OTPublicFeedItemViewController *)destinationViewController;
        controller.feedItem = self.selectedFeedItem;
    }
    else if([segue.identifier isEqualToString:@"ActiveFeedItemDetailsSegue"]) {
        OTActiveFeedItemViewController *controller = (OTActiveFeedItemViewController *)destinationViewController;
        controller.feedItem = self.selectedFeedItem;
        controller.inviteBehaviorTriggered = self.inviteBehaviorTriggered;
        self.inviteBehaviorTriggered = NO;
    }
    else if ([segue.identifier isEqualToString:@"OTWebViewSegue"]) {
        
        [OTSafariService launchInAppBrowserWithUrlString:self.webview viewController:self.navigationController];
        self.webview = nil;
    }
}

- (void)sendCloseMail: (NSNotification *)notification {
    OTCloseReason reason = [[notification.userInfo objectForKey:@kNotificationSendReasonKey] intValue];
    OTEntourage *feedItem = [notification.userInfo objectForKey:@kNotificationFeedItemKey];
    [self.mailSender sendCloseMail:reason forItem: feedItem];
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

@end
