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
#import "OTEncounter.h"

// Service
#import "OTPoiService.h"

// Framework
#import <MapKit/MKMapView.h>
#import <WYPopoverController/WYPopoverController.h>
#import <MapKit/MapKit.h>
#import "KPClusteringController.h"
#import "KPAnnotation.h"

#import "NSUserDefaults+OT.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTMapViewController () <MKMapViewDelegate, OTCalloutViewControllerDelegate, OTMeetingCalloutViewControllerDelegate, OTCreateMeetingViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(weak, nonatomic) IBOutlet UIButton *mapButton;
@property(weak, nonatomic) IBOutlet UIButton *listButton;
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) NSArray *categories;
@property(nonatomic, strong) NSArray *pois;
@property(nonatomic, strong) NSMutableArray *encounters;

@property(nonatomic, strong) WYPopoverController *popover;
@property(nonatomic, strong) KPClusteringController *clusteringController;

@property(nonatomic) BOOL isRegionSetted;
@property(nonatomic, strong) NSMutableArray *tableData;
@property(nonatomic, strong) CLLocationManager *locationManager;

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
	[self refreshMap];
	[self createMenuButton];
	[self configureView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self refreshMap];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"currentUser"];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)configureView
{
    self.title = NSLocalizedString(@"mapviewcontroller_title", @"");
    self.tableData = [self filterCurrentAnnotations:[self.mapView annotationsInMapRect:self.mapView.visibleMapRect]];

    if (self.mapButton.isSelected)
    {
        [self configureMapView];
    }
    else if (self.listButton.isSelected)
    {
        [self configureListView];
    }
}

- (void)configureMapView
{
    [self.tableView setHidden:YES];
}

- (void)configureListView
{
    [self.tableView setHidden:NO];
}

- (void)registerObserver
{
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"currentUser"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
}

- (void)refreshMap
{
    [[OTPoiService new] poisAroundCoordinate:self.mapView.centerCoordinate
                                    distance:[self mapHeight]
                                     success:^(NSArray *categories, NSArray *pois, NSArray *encounters)
                                     {
                                         [self.indicatorView setHidden:YES];

                                         self.categories = categories;
                                         self.pois = pois;
                                         self.encounters = [encounters mutableCopy];

                                         [self feedMapViewWithPoiArray:pois];
                                         [self feedMapViewWithEncountersArray:encounters];
                                     }
                                     failure:^(NSError *error)
                                     {
                                         [self registerObserver];
                                         [self.indicatorView setHidden:YES];
                                     }];
}

- (CLLocationDistance)mapHeight
{
    MKMapPoint mpTopRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
            self.mapView.visibleMapRect.origin.y);

    MKMapPoint mpBottomRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
            self.mapView.visibleMapRect.origin.y + self.mapView.visibleMapRect.size.height);

    CLLocationDistance vDist = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight) / 1000.f;

    return vDist;
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

- (NSMutableArray *)filterCurrentAnnotations:(NSSet *)annots
{
    NSMutableArray *annotationsToAdd = [[NSMutableArray alloc] init];

    for (id a in[annots allObjects])
    {
        if ([a isKindOfClass:[KPAnnotation class]])
        {
            for (id e in[a annotations])
            {
                if ([e isKindOfClass:[OTEncounterAnnotation class]])
                {
                    [annotationsToAdd addObject:e];
                }
            }
        }
    }

    return annotationsToAdd;
}

- (NSString *)encounterAnnotationToString:(OTEncounterAnnotation *)annotation
{
    OTEncounter *encounter = [annotation encounter];
    NSString *cellTitle = [NSString stringWithFormat:@"%@ a rencontré %@",
                                                     encounter.userName,
                                                     encounter.streetPersonName];

    return cellTitle;
}

- (void)insertCurrentAnnotationsInTableView:(NSMutableArray *)annotationsToAdd
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSArray *toInsert = [[NSArray alloc] initWithArray:annotationsToAdd];
    NSInteger nbAnnotationsToAdd = [toInsert count];

    if (nbAnnotationsToAdd > 0)
    {
        [self.tableData removeAllObjects];
        [self.tableData addObjectsFromArray:toInsert];

        for (int i = 0; i < nbAnnotationsToAdd; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }

        [self.tableView reloadData];
    }
}

- (void)displayEncounter:(OTEncounterAnnotation *)simpleAnnontation
{
    OTMeetingCalloutViewController *controller = (OTMeetingCalloutViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"OTMeetingCalloutViewController"];
    controller.delegate = self;

	OTEncounterAnnotation *encounterAnnotation = (OTEncounterAnnotation *)simpleAnnontation;
	OTEncounter *encounter = encounterAnnotation.encounter;
    [self presentViewController:controller animated:YES completion:nil];
	[controller configureWithEncouter:encounter];


	[Flurry logEvent:@"Open_Encounter_From_Map" withParameters:@{ @"encounter_id" : encounterAnnotation.encounter.sid }];
}

/********************************************************************************/
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = nil;

    if ([annotation isKindOfClass:[OTCustomAnnotation class]])
    {
        OTCustomAnnotation *customAnnotation = (OTCustomAnnotation *) annotation;
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:customAnnotation.annotationIdentifier];

        if (!annotationView)
        {
            annotationView = customAnnotation.annotationView;
        }
        annotationView.annotation = annotation;
    }
    else if ([annotation isKindOfClass:[KPAnnotation class]])
    {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *) annotation;

        if ([kingpinAnnotation isCluster])
        {
            JSBadgeView *badgeView;
            annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterClusterAnnotationIdentifier];
            if (!annotationView)
            {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:kingpinAnnotation reuseIdentifier:kEncounterClusterAnnotationIdentifier];
                annotationView.canShowCallout = NO;
                annotationView.image = [UIImage imageNamed:@"rencontre.png"];
                badgeView = [[JSBadgeView alloc] initWithParentView:annotationView alignment:JSBadgeViewAlignmentBottomCenter];
            }
            else
            {
                for (UIView *subview in annotationView.subviews)
                {
                    if ([subview isKindOfClass:JSBadgeView.class])
                    {
                        badgeView = (JSBadgeView *) subview;
                    }
                }
            }
            badgeView.badgeText = [NSString stringWithFormat:@"%lu", (unsigned long) kingpinAnnotation.annotations.count];
        }
        else
        {
            id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
            if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]])
            {
                annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterAnnotationIdentifier];
                if (!annotationView)
                {
                    annotationView = ((OTEncounterAnnotation *) simpleAnnontation).annotationView;
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
    [self insertCurrentAnnotationsInTableView:[self filterCurrentAnnotations:[mapView annotationsInMapRect:mapView.visibleMapRect]]];
    [self refreshMap];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:NO];

    if ([view.annotation isKindOfClass:[OTCustomAnnotation class]])
    {
        // Start up our view controller from a Storyboard
        OTCalloutViewController *controller = (OTCalloutViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"OTCalloutViewController"];
        controller.delegate = self;

        UIView *popView = [controller view];

        popView.frame = CGRectOffset(view.frame, .0f, CGRectGetHeight(popView.frame) + 10000.f);

        [UIView animateWithDuration:.3f
                         animations:^
                         {
                             popView.frame = CGRectOffset(popView.frame, .0f, -CGRectGetHeight(popView.frame));
                         }];

        OTCustomAnnotation *annotation = [((MKAnnotationView *) view) annotation];

        [controller configureWithPoi:annotation.poi];

        self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
        [self.popover setTheme:[WYPopoverTheme themeForIOS7]];

        [self.popover presentPopoverFromRect:view.bounds
                                      inView:view
                    permittedArrowDirections:WYPopoverArrowDirectionNone
                                    animated:YES
                                     options:WYPopoverAnimationOptionFadeWithScale];
        [Flurry logEvent:@"Open_POI_From_Map" withParameters:@{@"poi_id" : annotation.poi.sid}];
    }
    else if ([view.annotation isKindOfClass:[KPAnnotation class]])
    {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *) view.annotation;
        if ([kingpinAnnotation isCluster])
        {
            // Do nothing
        }
        else
        {
            id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
            if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]])
            {
                [self displayEncounter:(OTEncounterAnnotation *) simpleAnnontation];
            }
        }
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

/********************************************************************************/
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"EncounterItem";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.textLabel.text = [self encounterAnnotationToString:self.tableData[(NSUInteger) indexPath.row]];
    return cell;
}

/********************************************************************************/
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OTEncounterAnnotation *annotationToDisplay = self.tableData[(NSUInteger) indexPath.row];
    [self displayEncounter:annotationToDisplay];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)mapButtonDidTap:(id)sender
{
    [self.mapButton setSelected:YES];
    [self.listButton setSelected:NO];
    [self configureView];
}

- (IBAction)listButtonDidTap:(id)sender
{
    [self.mapButton setSelected:NO];
    [self.listButton setSelected:YES];
    [self configureView];
}

- (IBAction)zoomToCurrentLocation:(id)sender
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
    OTCreateMeetingViewController *controller = (OTCreateMeetingViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"OTCreateMeetingViewController"];
    controller.delegate = self;

    [controller configureWithLocation:self.mapView.region.center];

    [self.navigationController pushViewController:controller animated:YES];
}

@end
