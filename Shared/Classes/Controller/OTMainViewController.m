//
//  OTMapViewController.m
//  entourage
//
//  Created by Louis Davin on 22/08/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

// Controller
#import "OTMainViewController.h"
#import "UIViewController+menu.h"
#import "OTCalloutViewController.h"
#import "OTMapOptionsViewController.h"
#import "OTTourOptionsViewController.h"
#import "OTQuitFeedItemViewController.h"
#import "UIView+entourage.h"
#import "OTUserViewController.h"
#import "OTTourCreatorViewController.h"
#import "OTFeedItemFiltersViewController.h"
#import "OTPublicFeedItemViewController.h"
#import "OTActiveFeedItemViewController.h"
#import "OTMyEntouragesViewController.h"
#import "OTToursMapDelegate.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"
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
#import <QuartzCore/QuartzCore.h>
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
#import "OTNewsFeedsSourceDelegate.h"
#import "OTNewsFeedsSourceBehavior.h"
#import "OTTourCreatorBehavior.h"
#import "OTTourCreatorBehaviorDelegate.h"
#import "OTStartTourAnnotation.h"
#import "OTNoDataBehavior.h"
#import "OTUnreadMessagesService.h"
#import "OTMailSenderBehavior.h"
#import "OTAppDelegate.h"
#import "OTSavedFilter.h"
#import "OTEditEncounterBehavior.h"
#import "OTTapViewBehavior.h"
#import "OTToggleVisibleBehavior.h"
#import "OTCollectionSourceBehavior.h"
#import "OTHeatzonesCollectionSource.h"
#import <Kingpin/KPClusteringController.h>
#import <Kingpin/KPAnnotation.h>
#import "OTAnnouncement.h"
#import "OTMapView.h"
#import "entourage-Swift.h"
#import "OTHTTPRequestManager.h"
#import "OTSafariService.h"
#import "OTAppConfiguration.h"
#import "OTEntourageAnnotation.h"
#import "OTNeighborhoodAnnotation.h"
#import "OTPrivateCircleAnnotation.h"
#import "OTOutingAnnotation.h"
#import "OTCrashlyticsHelper.h"

#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define FEEDS_REQUEST_DISTANCE_KM 10

#define LONGPRESS_DELTA 65.0f
#define MAX_DISTANCE 250.0 //meters
#define NUMBER_OF_LAUNCH_CHECK 4

@interface OTMainViewController ()
<
UIGestureRecognizerDelegate,
UIScrollViewDelegate,
OTFeedItemsTableViewDelegate,
OTTourCreatorDelegate,
OTFeedItemQuitDelegate,
OTFeedItemsFilterDelegate,
OTNewsFeedsSourceDelegate,
OTTourCreatorBehaviorDelegate,
OTHeatzonesCollectionViewDelegate
>

@property (nonatomic, weak) IBOutlet OTFeedItemsTableView           *tableView;
@property (nonatomic, weak) IBOutlet OTMapDelegateProxyBehavior     *mapDelegateProxy;
@property (nonatomic, weak) IBOutlet OTOverlayFeederBehavior        *overlayFeeder;
@property (nonatomic, weak) IBOutlet OTTapEntourageBehavior         *tapEntourage;
@property (nonatomic, weak) IBOutlet OTJoinBehavior                 *joinBehavior;
@property (nonatomic, weak) IBOutlet OTStatusChangedBehavior        *statusChangedBehavior;
@property (nonatomic, weak) IBOutlet OTEditEntourageBehavior        *editEntourgeBehavior;
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
@property (nonatomic, strong) IBOutlet OTCollectionSourceBehavior   *heatzonesDataSource;
@property (nonatomic, strong) IBOutlet OTHeatzonesCollectionSource  *heatzonesCollectionDataSource;
@property (nonatomic, strong) IBOutlet UIView  *hideScreenPlaceholder;
@property (nonatomic, strong) IBOutlet UILabel  *hideScreenPlaceholderTitle;
@property (nonatomic, strong) IBOutlet UILabel  *hideScreenPlaceholderSubtitle;

//New buttons
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ui_constraint_view_menu_height;
@property (weak, nonatomic) IBOutlet UIView *ui_view_top_menu;
@property (weak, nonatomic) IBOutlet UIButton *ui_button_filters;
@property (weak, nonatomic) IBOutlet UIButton *ui_button_map_list;
@property (weak, nonatomic) IBOutlet UIView *ui_view_encounter;
@property (weak, nonatomic) IBOutlet UIView *ui_view_selector_menu_all;
@property (weak, nonatomic) IBOutlet UIView *ui_view_selector_menu_events;
@property (weak, nonatomic) IBOutlet UIView *ui_view_selector_menu_encounters;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_menu_all;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_menu_events;
@property (weak, nonatomic) IBOutlet UILabel *ui_label_menu_encounters;

@property (nonatomic) BOOL isEventMenuSelected, isEncounterSelected;
@property (nonatomic, strong) OTNewsFeedsFilter *encounterFilter;

@property (nonatomic, strong) KPClusteringController *clusteringController;
@property (nonatomic) double entourageScale;
@property (nonatomic) BOOL encounterFromTap;
@property (nonatomic) BOOL forceReloadingFeeds;
@property (nonatomic) BOOL isAskForHelp;

@property (nonatomic) BOOL isFirstInitView;
@end

@implementation OTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstInitView = YES;
    
    [self setup];
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([OTAppConfiguration shouldShowIntroTutorial:currentUser]) {
        [OTAppState presentTutorialScreen];
    }
    
    [self configureActionsButton];
    
    [self changeViewMenuState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAllsFromNotification)
                                                 name:@"showAlls"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showEventsFromNotification)
                                                 name:@"showEvents"
                                               object:nil];
}

-(void)checkProfil {
    if (!self.isFirstLoad) {
        return;
    }
    
    BOOL isAfterLogin = [[NSUserDefaults standardUserDefaults] boolForKey: @"checkAfterLogin"];
    BOOL noMoreDemand = [[NSUserDefaults standardUserDefaults] boolForKey: @"noMoreDemand"];
    NSInteger numberOfLaunch = [[NSUserDefaults standardUserDefaults] integerForKey:@"nbOfLaunch"];
   
    numberOfLaunch = numberOfLaunch + 1;
    [[NSUserDefaults standardUserDefaults]setInteger:numberOfLaunch forKey:@"nbOfLaunch"];
    
    BOOL hasToShow = NO;
    if (!noMoreDemand) {
        hasToShow = (numberOfLaunch > 0 && numberOfLaunch % NUMBER_OF_LAUNCH_CHECK == 0) ? YES : NO;
    }
 
    if (isAfterLogin || hasToShow) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"checkAfterLogin"];
        
        OTUser * currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
        
        if (currentUser.goal == nil || currentUser.goal.length == 0) {
            NSString *message = OTLocalizedString(@"login_info_pop_action");
            
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"login_pop_information") message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:OTLocalizedString(@"pop_info_entourage_custom_yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSURL *deepL = [NSURL URLWithString:@"entourage://profileAction"];
                [[OTDeepLinkService new] handleDeepLink:deepL];
            }];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:OTLocalizedString(@"pop_info_entourage_custom_no") style:UIAlertActionStyleDefault handler:nil];
            
            UIAlertAction *actionNoMore = [UIAlertAction actionWithTitle:OTLocalizedString(@"pop_info_entourage_custom_no_more") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreDemand"];
            }];
            
            [alertVC addAction:actionNoMore];
            [alertVC addAction:actionCancel];
            [alertVC addAction:action];
            
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }
}

-(void) showAllsFromNotification {
    [self action_show_all:self];
    [self showFeedsList];
    [self configureNavigationBar];
}
-(void) showEventsFromNotification {
    [self action_show_events:self];
    [self showFeedsList];
    [self configureNavigationBar];
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
    self.heatzonesCollectionDataSource.heatzonesDelegate = self;
    [self.heatzonesCollectionDataSource initialize];
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
    
    [self switchToNewsfeed];
    [self reloadFeeds];
    
    [self.mapDelegateProxy.delegates addObject:self];
    self.entourageScale = 1.0;
    [self addObservers];
    
    [self showToursListAction];
    
    [self.ui_label_menu_all setText:OTLocalizedString(@"home_tab_all").uppercaseString];
    [self.ui_label_menu_events setText:OTLocalizedString(@"home_tab_events").uppercaseString];
    [self.ui_label_menu_encounters setText:OTLocalizedString(@"home_tab_encounter").uppercaseString];
    
    [self checkOnboarding];
}

-(void)checkOnboarding {
    
    int userType = (int) [[NSUserDefaults standardUserDefaults] integerForKey:@"userType"];
    
    BOOL isFromOnboarding = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFromOnboarding"];
    
    if (isFromOnboarding) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFromOnboarding"];
        
        if (userType == 1) { //Neighbour
            [self.currentFilter setNeighbourFilters];
        }
        else if(userType == 2) { // Alone
            [self.currentFilter setAloneFilters];
        }
        [self changeFilterButton];
        
        NSNotification *notif = [[NSNotification alloc]initWithName:@"showToolTip" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notif];
    }
    
    [NSUserDefaults standardUserDefaults].savedNewsfeedsFilter = [OTSavedFilter fromNewsFeedsFilter:self.currentFilter];
}

-(void) changeFilterButton {
    if (self.isEncounterSelected) {
        NSLog(@"***** is encounter nil ? %@",self.encounterFilter);
        if (self.encounterFilter == nil) {
            NSLog(@"***** Encouter filter null on reload feeds");
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
    else {
        if ([self.currentFilter isDefaultFilters]) {
            [self.ui_button_filters setTitle:OTLocalizedString(@"home_button_filters").uppercaseString forState:UIControlStateNormal];
        }
        else {
            [self.ui_button_filters setTitle:OTLocalizedString(@"home_button_filters_on").uppercaseString forState:UIControlStateNormal];
        }
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
                                             selector:@selector(updateGroupUnreadState:)
                                                 name:kUpdateGroupUnreadStateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTotalUnreadCountBadge:)
                                                 name:kUpdateTotalUnreadCountNotification
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
    
    if (self.isFirstInitView) {
        [self.ui_view_top_menu.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.ui_view_top_menu.layer setShadowOpacity:0.5];
        [self.ui_view_top_menu.layer setShadowRadius:4.0];
        self.ui_view_top_menu.layer.masksToBounds = NO;
        CGRect _rect = CGRectMake(0, self.ui_view_top_menu.bounds.size.height, self.view.frame.size.width, self.ui_view_top_menu.layer.shadowRadius);
        CGPathRef shadowPath = [[UIBezierPath bezierPathWithRect:_rect] CGPath];
        [self.ui_view_top_menu.layer setShadowPath:shadowPath];
        self.isFirstInitView = NO;
        
        [OTLogger logEvent:View_Start_Feeds];
    }
    
    [OTAppConfiguration updateAppearanceForMainTabBar];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self.newsFeedsSourceBehavior resume];
    [self.heatzonesCollectionDataSource refresh];
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
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self checkProfil];
    });
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

- (void)loadHeatzonesCollectionViewWithItems: (NSMutableArray *)itemsTapped {
    NSMutableArray *feeds = [[NSMutableArray alloc] init];
    for (CLLocation *coordinates in itemsTapped) {
        for (OTEntourage *item in self.newsFeedsSourceBehavior.feedItems) {
            if ([item isKindOfClass:[OTEntourage class]]) {
                if (item.location.coordinate.latitude == coordinates.coordinate.latitude &&
                    item.location.coordinate.longitude == coordinates.coordinate.longitude) {
                    [feeds addObject:item];
                }
                else {
                    NSLog(@"Invalide location for event: %@", item.title);
                }
            }
        }
    }
    
    [self.toggleCollectionView toggle:[feeds count] > 0 animated:YES];
    
    if (feeds.count > 0) {
        [self.heatzonesDataSource updateItems:feeds];
    }
    [self.heatzonesCollectionDataSource refresh];
}

- (void)switchToNewsfeed {
    [OTLogger logEvent:@"Screen06_1FeedView"];
    [self.tableView switchToFeeds];
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

- (void)switchToEvents {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.00 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self action_show_events:self];
    });
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

- (IBAction)action_show_all:(id)sender {
    [self.tableView showAllFeedItemsAction];
    self.isEventMenuSelected = NO;
    self.isEncounterSelected = NO;
    [self changeViewMenuState];
}
- (IBAction)action_show_events:(id)sender {
    [self.tableView showEventsOnlyAction];
    self.isEventMenuSelected = YES;
    self.isEncounterSelected = NO;
    [self changeViewMenuState];
}
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
    if (self.isFirstLoad) {
        self.isEventMenuSelected = NO;
        self.isEncounterSelected = NO;
        
        if (IS_PRO_USER && OTAppConfiguration.supportsTourFunctionality) {
            [self.ui_view_encounter setHidden:NO];
        }
        else {
            [self.ui_view_encounter setHidden:YES];
        }
    }
    
    if (self.isEncounterSelected) {
        [self.ui_view_selector_menu_all setHidden:TRUE];
        [self.ui_view_selector_menu_events setHidden:TRUE];
        [self.ui_view_selector_menu_encounters setHidden:NO];
        [self.ui_label_menu_all setTextColor:UIColor.darkGrayColor];
        [self.ui_label_menu_events setTextColor:UIColor.darkGrayColor];
        [self.ui_label_menu_encounters setTextColor:UIColor.appOrangeColor];
        [self.ui_button_filters setHidden: NO];
    }
    else {
        [self.ui_view_selector_menu_encounters setHidden:YES];
        [self.ui_label_menu_encounters setTextColor:UIColor.darkGrayColor];
        
        if (self.isEventMenuSelected) {
            [self.ui_view_selector_menu_all setHidden:TRUE];
            [self.ui_view_selector_menu_events setHidden:NO];
            [self.ui_label_menu_all setTextColor:UIColor.darkGrayColor];
            [self.ui_label_menu_events setTextColor:UIColor.appOrangeColor];
            [self.ui_button_filters setHidden: YES];
        }
        else {
            [self.ui_button_filters setHidden: NO];
            [self.ui_view_selector_menu_all setHidden:NO];
            [self.ui_view_selector_menu_events setHidden:TRUE];
            [self.ui_label_menu_all setTextColor:UIColor.appOrangeColor];
            [self.ui_label_menu_events setTextColor:UIColor.darkGrayColor];
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
    
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
    
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

- (void)showEntourages {
    [OTLogger logEvent:@"GoToMessages"];
    [self performSegueWithIdentifier:@"MyEntouragesSegue" sender:self];
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

- (void)entourageCreated:(NSNotification *)notification {
    if (self.currentFilter.isPro) {
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
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.isTourListDisplayed) {
            [OTLogger logEvent:Action_feed_showMap];
            [self showToursMapAction];
        }
        else {
            NSMutableArray *closeTapHeatzones = [self.tapEntourage hasTappedEntourageOverlay:sender];
            NSMutableArray *closeTapEntourages = [self.tapEntourage hasTappedEntourageAnnotation:sender];
            
            if (closeTapHeatzones.count > 0 && closeTapEntourages.count > 0) {
                [OTLogger logEvent:@"HeatzoneMapClick"];
                CLLocationCoordinate2D coordinate;
                if (self.tapEntourage.tappedEntourage) {
                    coordinate = self.tapEntourage.tappedEntourage.coordinate;
                } else {
                    coordinate = self.tapEntourage.tappedEntourageAnnotation.coordinate;
                }
                [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, MAPVIEW_CLICK_REGION_SPAN_X_METERS, MAPVIEW_CLICK_REGION_SPAN_Y_METERS) animated:YES];
                NSMutableArray *items = [[NSMutableArray alloc] initWithArray:closeTapHeatzones];
                [items addObjectsFromArray:closeTapEntourages];
                [self loadHeatzonesCollectionViewWithItems:items];
                
            }
            else if (closeTapHeatzones.count > 0) {
                [OTLogger logEvent:@"HeatzoneMapClick"];
                [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.tapEntourage.tappedEntourage.coordinate, MAPVIEW_CLICK_REGION_SPAN_X_METERS, MAPVIEW_CLICK_REGION_SPAN_Y_METERS) animated:YES];
                
                [self loadHeatzonesCollectionViewWithItems:closeTapHeatzones];
                
            }
            else if (closeTapEntourages.count > 0) {
                [OTLogger logEvent:@"AnnotationMapClick"];
                [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.tapEntourage.tappedEntourageAnnotation.coordinate, MAPVIEW_CLICK_REGION_SPAN_X_METERS, MAPVIEW_CLICK_REGION_SPAN_Y_METERS) animated:YES];
                [self loadHeatzonesCollectionViewWithItems:closeTapEntourages];
            }
            else {
                [self.toggleCollectionView toggle:NO animated:YES];
            }
        }
        
        [self configureNavigationBar];
    }
}

#pragma mark - EntourageEditorDelegate

- (void)didEditEntourage:(OTEntourage *)entourage {
    if ([entourage isOuting] && ![OTAppConfiguration shouldAutoLaunchEditorOnAddAction]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    [self.editEntourgeBehavior.owner dismissViewControllerAnimated:YES completion:^{
        if (![entourage.status isEqualToString:ENTOURAGE_STATUS_SUSPENDED]) {
            [self forceGetNewData];
            
            if (entourage.isPublic.boolValue) {
                self.inviteBehaviorTriggered = NO;
            } else {
                // Auto show the share popup only for entourage where a native popover is displayed
                self.inviteBehaviorTriggered = ![OTAppConfiguration shouldAutoLaunchEditorOnAddAction];
            }
            
            [self showFeedInfo:entourage];
        }
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

- (IBAction)doShowNewFeedItems:(UIButton*)sender {
    self.nouveauxFeedItemsButton.hidden = YES;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Feeds Table View Delegate

- (void)loadMoreData {
    [OTLogger logEvent:@"ScrollListPage"];
    [self.newsFeedsSourceBehavior loadMoreItems];
}

- (void)showFeedInfo:(OTFeedItem *)feedItem {
    self.selectedFeedItem = feedItem;
    if ([[[OTFeedItemFactory createFor:feedItem] getStateInfo] isPublic]) {
        [OTLogger logEvent:@"OpenEntouragePublicPage"];
        
        if ([feedItem isTour]) {
            [self performSegueWithIdentifier:@"PublicFeedItemDetailsSegue" sender:self];
        }
        else {
            [self performSegueWithIdentifier:@"pushDetailFeedNew" sender:self];
        }
    }
    else {
        [OTLogger logEvent:@"OpenEntourageActivePage"];
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

- (void)showEventsOnly
{
    [OTLogger logEvent:Action_feed_showEvents];
    self.newsFeedsSourceBehavior.showEventsOnly = YES;
    self.newsFeedsSourceBehavior.showEncountersOnly = NO;
    self.forceReloadingFeeds = NO;
    [self.noDataBehavior switchedToEvents];
    [self configureNavigationBar];
    [self reloadFeeds];
}

- (void)showAllFeedItems
{
    [OTLogger logEvent:Action_feed_showAll];
    self.newsFeedsSourceBehavior.showEventsOnly = NO;
    self.newsFeedsSourceBehavior.showEncountersOnly = NO;
    self.forceReloadingFeeds = YES;
    [self.noDataBehavior switchedToNewsfeeds];
    [self configureNavigationBar];
    [self reloadFeeds];
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
    if([self.editEntourgeBehavior prepareSegue:segue])
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
    else if([segue.identifier isEqualToString:@"QuitFeedItemSegue"]) {
        OTQuitFeedItemViewController *controller = (OTQuitFeedItemViewController *)destinationViewController;
        controller.view.backgroundColor = [UIColor appModalBackgroundColor];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [OTAppState hideTabBar:YES];
        controller.feedItem = self.selectedFeedItem;
        controller.feedItemQuitDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"TourCreatorSegue"]) {
        [OTAppState hideTabBar:YES];
        OTTourCreatorViewController *controller = (OTTourCreatorViewController *)destinationViewController;
        controller.view.backgroundColor = [UIColor clearColor];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        controller.tourCreatorDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"EntourageEditor"]) {
        UINavigationController *navController = (UINavigationController*)destinationViewController;
        OTEntourageEditorViewController *controller = (OTEntourageEditorViewController *)navController.childViewControllers[0];
        controller.type = self.entourageType;
        CLLocation *currentLocation = self.tappedLocation ?
        self.tappedLocation :
        [[OTLocationManager sharedInstance] defaultLocationForNewActions];
        controller.location = currentLocation;
        controller.entourageEditorDelegate = self;
        controller.isAskForHelp = self.isAskForHelp;
        controller.isEditingEvent = self.addEditEvent;
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
    else if([segue.identifier isEqualToString:@"pushDetailFeedNew"]) {
        OTDetailActionEventViewController *controller = (OTDetailActionEventViewController *) destinationViewController;
        controller.feedItem = self.selectedFeedItem;
    }
    else if([segue.identifier isEqualToString:@"ActiveFeedItemDetailsSegue"]) {
        OTActiveFeedItemViewController *controller = (OTActiveFeedItemViewController *)destinationViewController;
        controller.feedItem = self.selectedFeedItem;
        controller.inviteBehaviorTriggered = self.inviteBehaviorTriggered;
        self.inviteBehaviorTriggered = NO;
    }
    else if([segue.identifier isEqualToString:@"MyEntouragesSegue"]) {
        OTMyEntouragesViewController *controller = (OTMyEntouragesViewController *)destinationViewController;
        controller.optionsDelegate = self;
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

- (void)updateGroupUnreadState:(NSNotification *) notification {
    BOOL refreshFeed = [notification.object boolForKey:kNotificationUpdateBadgeRefreshFeed defaultValue:YES];
    if (refreshFeed == YES)
        [self forceGetNewData];
}

- (void)updateTotalUnreadCountBadge:(NSNotification *) notification {
    NSNumber *totalUnreadCount = [notification.object numberForKey:kNotificationTotalUnreadCountKey];
    [OTAppState updateMessagesTabBadgeWithValue:totalUnreadCount.stringValue];
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
    [self.newsFeedsSourceBehavior removeAllFeedItems];
    [self.newsFeedsSourceBehavior getNewItems];
    [self reloadFeeds];
    [self feedMapWithFeedItems];
}

- (void)associationUpdated {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if(currentUser.partner == nil) {
        self.currentFilter.showFromOrganisation = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        defaults.savedNewsfeedsFilter = [OTSavedFilter fromNewsFeedsFilter:self.currentFilter];
    }
    [self reloadFeeds];
}

@end
