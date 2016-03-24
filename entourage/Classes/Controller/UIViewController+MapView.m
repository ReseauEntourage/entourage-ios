//
//  UIViewController+MapView.m
//  entourage
//
//  Created by Ciprian Habuc on 23/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIViewController+MapView.h"
#import "KPAnnotation.h"
#import "KPClusteringController.h"
#import "JSBadgeView.h"
#import "OTCustomAnnotation.h"
#import "OTEncounterAnnotation.h"
#import "OTTour.h"



@implementation UIViewController (MapView)

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)annotation;
        
        if ([kingpinAnnotation isCluster])
        {
            JSBadgeView *badgeView;
            annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterClusterAnnotationIdentifier];
            if (!annotationView)
            {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:kingpinAnnotation reuseIdentifier:kEncounterClusterAnnotationIdentifier];
                annotationView.canShowCallout = NO;
                annotationView.image = [UIImage imageNamed:@"report"];
                badgeView = [[JSBadgeView alloc] initWithParentView:annotationView alignment:JSBadgeViewAlignmentBottomCenter];
            }
            else
            {
                for (UIView *subview in annotationView.subviews) {
                    if ([subview isKindOfClass:JSBadgeView.class]) {
                        badgeView = (JSBadgeView *)subview;
                    }
                }
            }
            badgeView.badgeText = [NSString stringWithFormat:@"%lu", (unsigned long)kingpinAnnotation.annotations.count];
        }
        else
        {
            id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
            if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]]) {
                annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kEncounterAnnotationIdentifier];
                if (!annotationView) {
                    annotationView = ((OTEncounterAnnotation *)simpleAnnontation).annotationView;
                }
                annotationView.annotation = simpleAnnontation;
            }
        }
        annotationView.canShowCallout = YES;
    }
    
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //[self refreshMap];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
//    if (!self.isRegionSetted) {
//        self.isRegionSetted = YES;
//        [self zoomToCurrentLocation:nil];
//    }
}

- (void)startLocationUpdatesWithLocationManager:(CLLocationManager *)locationManager {
//    if (locationManager == nil) {
//        self.locationManager = [[CLLocationManager alloc] init];
//    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.activityType = CLActivityTypeFitness;
    
    locationManager.distanceFilter = 5; // meters
    
    [locationManager startUpdatingLocation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    
    if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *kingpinAnnotation = (KPAnnotation *)view.annotation;
        if ([kingpinAnnotation isCluster]) {
            // Do nothing
        }
        else {
            id <MKAnnotation> simpleAnnontation = [kingpinAnnotation.annotations anyObject];
            if ([simpleAnnontation isKindOfClass:[OTEncounterAnnotation class]]) {
                //[self displayEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view];
            }
        }
    }
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    for (CLLocation *newLocation in locations) {
//        
//        NSDate *eventDate = newLocation.timestamp;
//        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
//        
//        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
//            
//            if (self.locations.count > 0) {
//                
//                CLLocationCoordinate2D coords[2];
//                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
//                coords[1] = newLocation.coordinate;
//                
//                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
//                [self.mapView setRegion:region animated:YES];
//                
//                if (self.isTourRunning) {
//                    self.tour.distance += [newLocation distanceFromLocation:self.locations.lastObject];
//                    [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
//                    OTTourPoint *tourPoint = [[OTTourPoint alloc] initWithLocation:newLocation];
//                    [self.tour.tourPoints addObject:tourPoint];
//                    [self.pointsToSend addObject:tourPoint];
//                    [self sendTourPoints:self.pointsToSend];
//                    [self.pointsToSend removeLastObject];
//                }
//            }
//            
//            [self.locations addObject:newLocation];
//        }
//    }
//}

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
//    if ([overlay isKindOfClass:[MKPolyline class]]) {
//        MKPolyline *polyline = (MKPolyline *) overlay;
//        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];
//        
//        OTTour *tour = [self.drawnTours objectForKey:polyline];
//        if ([tour.tourType isEqualToString:@"medical"]) {
//            aRenderer.strokeColor = [UIColor redColor];
//        }
//        else if ([tour.tourType isEqualToString:@"barehands"]) {
//            aRenderer.strokeColor = [UIColor blueColor];
//        }
//        else if ([tour.tourType isEqualToString:@"alimentary"]) {
//            aRenderer.strokeColor = [UIColor greenColor];
//        }
//        
//        if (self.isTourRunning && tour == nil) {
//            if ([self.currentTourType isEqualToString:@"medical"]) {
//                aRenderer.strokeColor = [UIColor redColor];
//            }
//            else if ([self.currentTourType isEqualToString:@"barehands"]) {
//                aRenderer.strokeColor = [UIColor blueColor];
//            }
//            else if ([self.currentTourType isEqualToString:@"alimentary"]) {
//                aRenderer.strokeColor = [UIColor greenColor];
//            }
//        }
//        
//        aRenderer.lineWidth = 3;
//        return aRenderer;
//    }
//    return nil;
//}

#pragma mark - Navigation
//- (void)displayEncounter:(OTEncounterAnnotation *)simpleAnnontation withView:(MKAnnotationView *)view {
//    OTMeetingCalloutViewController *controller = (OTMeetingCalloutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OTMeetingCalloutViewController"];
//    controller.delegate = self;
//    
//    OTEncounterAnnotation *encounterAnnotation = (OTEncounterAnnotation *)simpleAnnontation;
//    OTEncounter *encounter = encounterAnnotation.encounter;
//    [controller setEncounter:encounter];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
//    [self presentViewController:navController animated:YES completion:nil];
//}


@end
