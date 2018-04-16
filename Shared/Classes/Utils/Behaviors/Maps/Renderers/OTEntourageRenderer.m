//
//  OTEntourageRenderer.m
//  entourage
//
//  Created by sergiu buceac on 9/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageRenderer.h"

#define EntourageCircleImage @"heatZone"

@implementation OTEntourageRenderer

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    MKMapRect theMapRect = self.overlay.boundingMapRect;
    CGRect theRect = [self rectForMapRect:theMapRect];
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    CGImageRef imageReference = [UIImage imageNamed:EntourageCircleImage].CGImage;
    CGContextDrawImage(context, theRect, imageReference);
}
@end
