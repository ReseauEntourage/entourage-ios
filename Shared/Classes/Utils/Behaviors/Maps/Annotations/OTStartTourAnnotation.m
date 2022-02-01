//
//  OTStartTourAnnotation.m
//  entourage
//
//  Created by sergiu buceac on 11/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTStartTourAnnotation.h"
#import "OTTourPoint.h"
#import "OTStartTourAnnotationView.h"

NSString *const kStartTourAnnotationIdentifier = @"OTStartTourIdentifier";

@interface OTStartTourAnnotation () <MKAnnotation>

@end

@implementation OTStartTourAnnotation

- (id)initWithTour:(OTTour *)tour {
    if(tour.tourPoints.count == 0)
        return nil;
    self = [super init];
    if(self) {
        self.tour = tour;
    }
    return self;
}

- (MKAnnotationView *)annotationView {
    OTStartTourAnnotationView *annotationView = [[OTStartTourAnnotationView alloc] initWithAnnotation:self reuseIdentifier:kStartTourAnnotationIdentifier];
    annotationView.canShowCallout = NO;
    return annotationView;
}

#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate {
    OTTourPoint *startPoint = self.tour.tourPoints[0];
    CLLocationCoordinate2D poiCoordinate = { .latitude = startPoint.latitude, .longitude =  startPoint.longitude };
    return poiCoordinate;
}

@end
