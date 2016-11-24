//
//  OTLocationSelectorViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 07/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTLocationSelectorViewController.h"
#import "UIColor+entourage.h"
#import "OTToolbar.h"
#import "OTConsts.h"
#import "MKMapView+entourage.h"
#import "OTLocationSearchTableViewController.h"
#import "UIStoryboard+entourage.h"
#import "OTEntourageEditorViewController.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"

#define SEARCHBAR_FRAME CGRectMake(16, 80, [UIScreen mainScreen].bounds.size.width-32, 48)

@interface OTLocationSelectorViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet OTToolbar *footerToolbar;

@property (nonatomic, strong)  UISearchBar *searchBar;

@property (nonatomic, strong) UISearchController *resultSearchController;
@property (nonatomic, strong) OTLocationSearchTableViewController *locationSearchTable;

@end

@implementation OTLocationSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    [self.footerToolbar setupDefault];
    self.title = OTLocalizedString(@"myLocation").uppercaseString;
    
    self.locationSearchTable = [[UIStoryboard entourageEditorStoryboard] instantiateViewControllerWithIdentifier:@"OTLocationSearchTableViewController"];
    self.resultSearchController = [[UISearchController alloc] initWithSearchResultsController:self.locationSearchTable];
    self.resultSearchController.searchResultsUpdater = self.locationSearchTable;

    self.searchBar = self.resultSearchController.searchBar;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.placeholder = OTLocalizedString(@"searchLocationPlaceholder");

    self.navigationItem.titleView = self.resultSearchController.searchBar;
    self.searchBar = self.resultSearchController.searchBar;
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

- (void)zoomToCurrentLocation:(id)sender {
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
        [self.footerToolbar setTitle:placemark.name];
        [self.footerToolbar setupDefault];
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
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark.thoroughfare !=  nil)
            [self.footerToolbar setTitle:placemark.thoroughfare ];
        else
            [self.footerToolbar setTitle:placemark.locality ];
    }];
    self.selectedLocation = location;
    if ([self.locationSelectionDelegate respondsToSelector:@selector(didSelectLocation:)]) {
        [self.locationSelectionDelegate didSelectLocation:location];
    }
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

@end
