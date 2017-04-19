//
//  OTTapEntourageBehavior.m
//  entourage
//
//  Created by sergiu buceac on 9/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTapEntourageBehavior.h"
#import "OTConsts.h"

#define ENTOURAGE_RADIUS_OFFSET 30

@implementation OTTapEntourageBehavior

- (BOOL)hasTappedEntourage:(UITapGestureRecognizer *)recognizer {
    return [self tapped:recognizer];
}

#pragma mark - private methods

- (BOOL)tapped:(UITapGestureRecognizer *)recognizer {
    self.tappedEntourage = nil;
    if (self.mapView.overlays.count == 0)
        return NO;
    CGPoint tapPoint = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapCoordinate = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
    for (id<MKOverlay> overlay in self.mapView.overlays)
        if ([overlay isKindOfClass:[MKCircle class]])
        {
            MKCircle *circle = overlay;
            CLLocationDistance distance = DBL_MAX;
            @autoreleasepool {
                CLLocation *first = [[CLLocation alloc] initWithLatitude:tapCoordinate.latitude longitude:tapCoordinate.longitude];
                CLLocation *second = [[CLLocation alloc] initWithLatitude:circle.coordinate.latitude longitude:circle.coordinate.longitude];
                distance = [first distanceFromLocation:second];
            }
            if(distance < ENTOURAGE_RADIUS - ENTOURAGE_RADIUS_OFFSET) {
                self.tappedEntourage = circle;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
                return YES;
            }
        }
    return NO;
}

@end
