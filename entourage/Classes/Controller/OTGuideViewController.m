//
//  OTGuideViewController.m
//  entourage
//
//  Created by Nicolas Telera on 09/09/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

// Controller
#import "OTGuideViewController.h"
#import "UIViewController+menu.h"
#import "OTGuideDetailsViewController.h"
#import "OTCalloutViewController.h"
#import "OTMapOptionsViewController.h"
#import "OTTourOptionsViewController.h"
#import "OTSWRevealViewController.h"
#import "OTConsts.h"

// View
#import "OTCustomAnnotation.h"
#import "JSBadgeView.h"

// Model
#import "OTPoi.h"
#import "OTPoiCategory.h"

// Service
#import "OTPoiService.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"

// Framework
#import <MapKit/MapKit.h>
#import <MapKit/MKMapView.h>
#import <WYPopoverController/WYPopoverController.h>

// User
#import "NSUserDefaults+OT.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTGuideViewController () <MKMapViewDelegate, OTCalloutViewControllerDelegate, OTOptionsDelegate>


// map

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic)CLLocationCoordinate2D currentMapCenter;

// markers

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *pois;

@property (nonatomic, strong) WYPopoverController *popover;

@property (nonatomic) BOOL isRegionSetted;
@property (nonatomic, strong) NSMutableArray *markers;

// tour options

@property (nonatomic, weak) IBOutlet UIButton *mapOptionsButton;
@property (nonatomic, weak) IBOutlet UIButton *tourOptionsButton;
@property (nonatomic) BOOL isTourRunning;

@end

@implementation OTGuideViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self zoomToCurrentLocation:nil];
    [self createMenuButton];
    [self configureView];
    [self updateOptionsButtons];
    
    self.markers = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:kNotificationLocationUpdated object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLocationUpdated object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self refreshMap];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)configureView {
    [self setupLogoImage];
    UIBarButtonItem *chatButton = [self setupChatsButton];
    [chatButton setTarget:self];
    [chatButton setAction:@selector(showEntourages)];
    //self.title = NSLocalizedString(@"guideviewcontroller_title", @"");
}

- (void)showEntourages {
    [self performSegueWithIdentifier:@"EntouragesSegue" sender:nil];
}

- (void)registerObserver {
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:NSLocalizedString(@"CURRENT_USER", @"")
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
}

- (void)refreshMap {
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

- (CLLocationDistance)mapHeight {
    MKMapPoint mpTopRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.height,
                                           self.mapView.visibleMapRect.origin.y);
    
    MKMapPoint mpBottomRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
                                              self.mapView.visibleMapRect.origin.y + self.mapView.visibleMapRect.size.height);
    
    CLLocationDistance vDist = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight) / 1000.f;
    
    return vDist;
}

- (void)feedMapViewWithPoiArray:(NSArray *)array {
    for (OTPoi *poi in array) {
        OTCustomAnnotation *annotation = [[OTCustomAnnotation alloc] initWithPoi:poi];
        if (![self.markers containsObject:annotation]) {
            [self.markers addObject:annotation];
        }
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.markers];
}

- (void)displayPoiDetails:(MKAnnotationView *)view {
    OTCustomAnnotation *annotation = nil;
    if([view.annotation isKindOfClass:[OTCustomAnnotation class]])
        annotation = (OTCustomAnnotation *)view.annotation;
    if (annotation == nil) return;
    
    [Flurry logEvent:@"Open_POI_From_Map" withParameters:@{ @"poi_id" : annotation.poi.sid }];
    
    [self performSegueWithIdentifier:@"OTGuideDetailsSegue" sender:annotation];
}

/********************************************************************************/
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
    MKAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[OTCustomAnnotation class]]) {
            OTCustomAnnotation *customAnnotation = (OTCustomAnnotation *)annotation;
            annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:customAnnotation.annotationIdentifier];
            if (!annotationView)
                annotationView = customAnnotation.annotationView;
            annotationView.annotation = annotation;
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLLocationDistance distance = (MKMetersBetweenMapPoints(MKMapPointForCoordinate(_currentMapCenter), MKMapPointForCoordinate(mapView.centerCoordinate))) / 1000.0f;
    if (distance > [self mapHeight]) {
        [self refreshMap];
        self.currentMapCenter = mapView.centerCoordinate;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    if([view.annotation isKindOfClass:[OTCustomAnnotation class]])
        [self displayPoiDetails:view];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.isRegionSetted) {
        self.isRegionSetted = YES;
        [self zoomToCurrentLocation:nil];
    }
}

- (void)locationUpdated:(NSNotification *)notification {
    NSArray *locations = [notification readLocations];
    for (CLLocation *newLocation in locations) {
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
            [self.mapView setRegion:region animated:YES];
        }
    }
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
#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover {
    [self.popover dismissPopoverAnimated:YES];
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

/********************************************************************************/
#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"OTMapOptionsSegue"]) {
        OTMapOptionsViewController *controller = (OTMapOptionsViewController *)segue.destinationViewController;
        controller.optionsDelegate = self;
        [controller setIsPOIVisible:YES];
    } else if([segue.identifier isEqualToString:@"OTTourOptionsSegue"]) {
        OTTourOptionsViewController *controller = (OTTourOptionsViewController *)segue.destinationViewController;
        controller.optionsDelegate = self;
        [controller setIsPOIVisible:YES];
    } else if ([segue.identifier isEqualToString:@"OTGuideDetailsSegue"]) {
        UINavigationController *navController = (UINavigationController*)segue.destinationViewController;
        OTGuideDetailsViewController *controller = navController.childViewControllers[0];
        controller.poi = ((OTCustomAnnotation*)sender).poi;
        controller.category = [self categoryById:controller.poi.categoryId];
    }
}

/********************************************************************************/
#pragma mark - OTOptionsDelegate

- (void)createTour {
    [self dismissViewControllerAnimated:NO completion:^{
        [self showCreateFeedItemAlertWithText:OTLocalizedString(@"poi_create_tour_alert")];

    }];
}

- (void)createDemande {
    [self dismissViewControllerAnimated:NO completion:^{
        [self showCreateFeedItemAlertWithText:OTLocalizedString(@"poi_create_demande_alert")];
    }];
}

- (void)createContribution {
    [self dismissViewControllerAnimated:NO completion:^{
        [self showCreateFeedItemAlertWithText:OTLocalizedString(@"poi_create_contribution_alert")];
    }];
}

- (void)showCreateFeedItemAlertWithText:(NSString *)text {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"cancelAlert") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancelAction];
    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"quitAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"OTMapViewSegue" sender:nil];
    }];
    [alert addAction:quitAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)togglePOI {
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"OTMapViewSegue" sender:nil];
    }];
}

-(void)dismissOptions {
    [self dismissViewControllerAnimated:NO completion:nil];
}

/********************************************************************************/
#pragma mark - OTOptionsDelegate - tours

- (void)createEncounter {
    [self dismissViewControllerAnimated:NO completion:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"poi_create_encounter_alert", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"cancelAlert") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:cancelAction];
        UIAlertAction *quitAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"quitAlert") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"OTMapViewSegue" sender:nil];
        }];
        [alert addAction:quitAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

/********************************************************************************/
#pragma mark - Tour Handling

-(void) setIsTourRunning:(BOOL)isTourRunning {
    _isTourRunning = isTourRunning;
    if (self.isViewLoaded) {
        [self updateOptionsButtons];
    }
}

- (void)updateOptionsButtons {
    self.mapOptionsButton.hidden = self.isTourRunning;
    self.tourOptionsButton.hidden = !self.isTourRunning;
}

@end
