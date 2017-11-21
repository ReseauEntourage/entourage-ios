//
//  OTLocationSelectorViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 07/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTLocationSelectorViewController.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "MKMapView+entourage.h"
#import "OTLocationSearchTableViewController.h"
#import "UIStoryboard+entourage.h"
#import "OTEntourageEditorViewController.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "UIBarButtonItem+factory.h"

#define SEARCHBAR_FRAME CGRectMake(16, 80, [UIScreen mainScreen].bounds.size.width-32, 48)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface OTLocationSelectorViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong)  UISearchBar *searchBar;

@property (nonatomic, strong) UISearchController *resultSearchController;
@property (nonatomic, strong) OTLocationSearchTableViewController *locationSearchTable;

@end

@implementation OTLocationSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    self.title = OTLocalizedString(@"myLocation").uppercaseString;
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate")
                                                        withTarget:self
                                                         andAction:@selector(saveNewLocation)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];

    self.locationSearchTable = [[UIStoryboard entourageEditorStoryboard] instantiateViewControllerWithIdentifier:@"OTLocationSearchTableViewController"];
    self.resultSearchController = [[UISearchController alloc] initWithSearchResultsController:self.locationSearchTable];
    self.resultSearchController.searchResultsUpdater = self.locationSearchTable;
    
    _searchBar = self.resultSearchController.searchBar;
    
    if (@available(iOS 11.0, *)) {
        self.title = OTLocalizedString(@"myLocation").uppercaseString;
        self.navigationItem.searchController = self.resultSearchController;
    }
    else
    {
        self.navigationItem.titleView = self.resultSearchController.searchBar;
    }
    
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.placeholder = OTLocalizedString(@"searchLocationPlaceholder");
    self.resultSearchController.hidesNavigationBarDuringPresentation = NO;
    self.resultSearchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    self.locationSearchTable.mapView = self.mapView;
    self.locationSearchTable.pinDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoomToCurrentLocation:) name:@kNotificationShowCurrentLocation object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self zoomToCurrentLocation:nil];
}

- (IBAction)zoomToCurrentLocation:(id)sender {
    if(!self.selectedLocation)
        self.selectedLocation = [OTLocationManager sharedInstance].currentLocation;
    if (self.selectedLocation) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.selectedLocation.coordinate, MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
        [self.mapView setRegion:region animated:YES];
        [self updateMapPin:self.selectedLocation];
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark - HandleMapSearch

- (void)dropPinZoomIn:(MKPlacemark *)placemark {
    self.selectedLocation = placemark.location;
    [self updateSelectedLocation:self.selectedLocation];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.mapView removeAnnotations:self.mapView.annotations];
        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = placemark.coordinate;
        annotation.title = placemark.name;
        [self.mapView addAnnotation:annotation];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
                                 
        [self.mapView setRegion:region];
        [self.activityIndicator stopAnimating];
    }];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id) annotation {
    if([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil)
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"myPin"];
    pin.annotation = annotation;
    pin.animatesDrop = YES;
    pin.draggable = YES;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        [annotationView.annotation setCoordinate:droppedAt];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        [self updateSelectedLocation:location];
    }
}

#pragma mark - private methods

- (void)updateSelectedLocation:(CLLocation *) location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        }
    }];
    self.selectedLocation = location;
}

- (void)updateMapPin:(CLLocation *)location {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil];
    [self.mapView removeAnnotations:self.mapView.annotations];
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = placemark.coordinate;
    annotation.title = placemark.name;
    [self.mapView addAnnotation:annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance( location.coordinate, MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
    [self.mapView setRegion:region animated:YES];
    [self.activityIndicator stopAnimating];
    [self updateSelectedLocation:location];
}

- (void)saveNewLocation {
    [OTLogger logEvent:@"ValidateLocationChange"];
    if ([self.locationSelectionDelegate respondsToSelector:@selector(didSelectLocation:)]) {
        [self.locationSelectionDelegate didSelectLocation:self.selectedLocation];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
