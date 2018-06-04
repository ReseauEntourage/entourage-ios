//
//  OTMapView.m
//  entourage
//
//  Created by veronica.gliga on 19/12/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTMapView.h"

typedef enum {
    OTMapViewTouchStateNormal,
    OTMapViewTouchStateZoomMode
} OTMapViewTouchState;

NSInteger const kOTMapViewTouchSensitivity = 1;
double const kOTMapViewBaseZoom = 2;

@interface OTMapView()

@property (nonatomic, assign) CGPoint zoomTouchLocation;
@property (nonatomic, assign) OTMapViewTouchState zoomTouchState;

-(void) applyZoom:(BOOL)increaseZoom withVelocity:(double)velocity;

@end

@implementation OTMapView

- (void)layoutSubviews
{
    static dispatch_once_t onceToken = 0;
    __weak typeof(self) weakMe = self;
    dispatch_once(&onceToken, ^{
        [weakMe setZoomTouchLocation:CGPointMake(FLT_MAX, FLT_MAX)];
    });
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 0) {
        return;
    }
    
    UITouch* touch = [[touches allObjects] firstObject];
    CGPoint newLocation = [touch locationInView:self];
    
    if (self.zoomTouchLocation.x == FLT_MAX && self.zoomTouchLocation.y == FLT_MAX) {
        [self setZoomTouchLocation:newLocation];
        [self setZoomTouchState:OTMapViewTouchStateNormal];
    }
    else {
        if (self.zoomTouchLocation.x == newLocation.x && self.zoomTouchLocation.y == newLocation.y) {
            [self setZoomTouchState:OTMapViewTouchStateZoomMode];
        }
        else {
            [self setZoomTouchState:OTMapViewTouchStateNormal];
        }
        
        [self setZoomTouchLocation:CGPointMake(FLT_MAX, FLT_MAX)];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 0) {
        return;
    }
    
    UITouch* touch = [[touches allObjects] firstObject];
    if(touch.tapCount != 2)
        return;
    CGPoint prevLocation = [touch previousLocationInView:self];
    CGPoint newLocation = [touch locationInView:self];
    CGFloat deltaYPoint = newLocation.y - prevLocation.y;
    
    if (fabs(deltaYPoint) > kOTMapViewTouchSensitivity) {
        if (deltaYPoint < 0) {
            [self applyZoom:YES withVelocity:0.05];
        }
        else {
            [self applyZoom:NO withVelocity:0.05];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setZoomTouchState:OTMapViewTouchStateNormal];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setZoomTouchState:OTMapViewTouchStateNormal];
}

- (void)zoomIn
{
    [self applyZoom:YES withVelocity:0.05];
}

- (void)zoomOut
{
    [self applyZoom:NO withVelocity:0.05];
}

- (void)applyZoom:(BOOL)increaseZoom withVelocity:(double)velocity
{
    CGFloat currentWidth = [self bounds].size.width;
    CGFloat currentHeight = [self bounds].size.height;
    
    MKCoordinateRegion currentRegion = [self region];
    double latitudePerPoint = currentRegion.span.latitudeDelta / currentWidth;
    double longitudePerPoint = currentRegion.span.longitudeDelta / currentHeight;
    
    double zoomFactor = pow(kOTMapViewBaseZoom, velocity);
    
    double newLatitudePerPoint;
    double newLongitudePerPoint;
    
    if (increaseZoom) {
        newLatitudePerPoint = latitudePerPoint / zoomFactor;
        newLongitudePerPoint = longitudePerPoint / zoomFactor;
    } else {
        newLatitudePerPoint = latitudePerPoint * zoomFactor;
        newLongitudePerPoint = longitudePerPoint * zoomFactor;
    }
    
    CLLocationDegrees newLatitudeDelta = newLatitudePerPoint * currentWidth;
    CLLocationDegrees newLongitudeDelta = newLongitudePerPoint * currentHeight;
    
    if (newLatitudeDelta <= 90 && newLongitudeDelta <= 90) {
        MKCoordinateRegion mapRegion;
        mapRegion.center = self.centerCoordinate;
        mapRegion.span.latitudeDelta = newLatitudeDelta;
        mapRegion.span.longitudeDelta = newLongitudeDelta;
        [self setRegion:mapRegion animated:NO];
    }
}

@end
