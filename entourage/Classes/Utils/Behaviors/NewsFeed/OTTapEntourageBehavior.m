//
//  OTTapEntourageBehavior.m
//  entourage
//
//  Created by sergiu buceac on 9/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTapEntourageBehavior.h"

@implementation OTTapEntourageBehavior

- (BOOL)hasTappedEntourage:(UITapGestureRecognizer *)recognizer {
    return [self tapped:recognizer];
}

#pragma mark - private methods

- (BOOL)tapped:(UITapGestureRecognizer *)recognizer {
    if (self.mapView.overlays.count == 0)
        return NO;
    CGPoint tapPoint = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapCoordinate = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
    MKMapPoint point = MKMapPointForCoordinate(tapCoordinate);
    for (id<MKOverlay> overlay in self.mapView.overlays)
        if ([overlay isKindOfClass:[MKCircle class]])
        {
            MKCircle *circle = overlay;
            MKCircleRenderer *circleRenderer = (MKCircleRenderer *)[self.mapView rendererForOverlay:circle];
            CGPoint datapoint = [circleRenderer pointForMapPoint:point];
            [circleRenderer invalidatePath];
            if (CGPathContainsPoint(circleRenderer.path, nil, datapoint, false)) {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
                return YES;
            }
        }
    return NO;
}

@end
