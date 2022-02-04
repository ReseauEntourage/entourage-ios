//
//  OTTapEntourageBehavior.m
//  entourage
//
//  Created by sergiu buceac on 9/11/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTTapEntourageBehavior.h"
#import "OTConsts.h"

#define ENTOURAGE_RADIUS_OFFSET 30

@implementation OTTapEntourageBehavior

- (NSMutableArray *)hasTappedEntourageOverlay:(UITapGestureRecognizer *)recognizer {
    return [self tappedOverlay:recognizer];
}

- (NSMutableArray *)hasTappedEntourageAnnotation:(UITapGestureRecognizer *)recognizer {
    return [self tappedAnnotation:recognizer];
}

#pragma mark - private methods

- (NSMutableArray *)tappedOverlay:(UITapGestureRecognizer *)recognizer {
    self.tappedEntourage = nil;
    NSMutableArray *entourages = [[NSMutableArray alloc] init];
    
    if (self.mapView.overlays.count == 0) {
        return entourages;
    }
    
    CGPoint tapPoint = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapCoordinate = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        if ([overlay isKindOfClass:[MKCircle class]]) {
            MKCircle *circle = overlay;
            CLLocationDistance distance = DBL_MAX;
            CLLocation *first;
            CLLocation *second;
            @autoreleasepool {
                first = [[CLLocation alloc] initWithLatitude:tapCoordinate.latitude
                                                               longitude:tapCoordinate.longitude];
                second = [[CLLocation alloc] initWithLatitude:circle.coordinate.latitude
                                                                longitude:circle.coordinate.longitude];
                distance = [first distanceFromLocation:second];
            }
            
            if (distance < ENTOURAGE_RADIUS - ENTOURAGE_RADIUS_OFFSET) {
                self.tappedEntourage = circle;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
                [entourages addObject:second];
            }
        }
    }
    
    return entourages;
}

- (NSMutableArray *)tappedAnnotation:(UITapGestureRecognizer *)recognizer {
    self.tappedEntourageAnnotation = nil;
    NSMutableArray *entourages = [[NSMutableArray alloc] init];
    
    if (self.mapView.annotations.count == 0) {
        return entourages;
    }
    
    CGPoint tapPoint = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapCoordinate = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[OTEntourageAnnotation class]]) {
            OTEntourageAnnotation *circle = (OTEntourageAnnotation*)annotation;
            CLLocationDistance distance = DBL_MAX;
            CLLocation *first;
            CLLocation *second;
            @autoreleasepool {
                first = [[CLLocation alloc] initWithLatitude:tapCoordinate.latitude
                                                   longitude:tapCoordinate.longitude];
                second = [[CLLocation alloc] initWithLatitude:circle.coordinate.latitude
                                                    longitude:circle.coordinate.longitude];
                distance = [first distanceFromLocation:second];
            }
            
            if (distance < ENTOURAGE_RADIUS - ENTOURAGE_RADIUS_OFFSET) {
                self.tappedEntourageAnnotation = circle;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
                [entourages addObject:second];
            }
        }
    }
    
    return entourages;
}

@end
