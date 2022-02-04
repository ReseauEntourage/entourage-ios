//
//  OTEncounterAnnotation.m
//  entourage
//
//  Created by Mathieu Hausherr on 11/10/14.
//  Copyright (c) 2014 Entourage. All rights reserved.
//

#import "OTEncounterAnnotation.h"

// Model
#import "OTEncounter.h"

// Framework
#import <MapKit/MKMapView.h>


NSString *const kEncounterAnnotationIdentifier = @"OTEncounterAnnotationIdentifier";
NSString *const kEncounterClusterAnnotationIdentifier = @"OTEncounterClusterAnnotationIdentifier";

@interface OTEncounterAnnotation () <MKAnnotation>

@end

@implementation OTEncounterAnnotation

/********************************************************************************/
#pragma mark - Public methods

- (id)initWithEncounter:(OTEncounter *)encounter
{
    self = [super init];
    if (self)
    {
        _encounter = encounter;
    }
    return self;
}

/********************************************************************************/
#pragma mark - MKAnnotation protocol

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D poiCoordinate = { .latitude =  self.encounter.latitude, .longitude =  self.encounter.longitude };
    
    return poiCoordinate;
}

- (NSString *)title
{
    return self.encounter.streetPersonName;
}

- (NSString *)subtitle
{
    return self.encounter.userName;
}

- (MKAnnotationView *)annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self
                                                                    reuseIdentifier:kEncounterAnnotationIdentifier];
    
    annotationView.canShowCallout = NO;
    annotationView.image = [UIImage imageNamed:@"report"];
    
    return annotationView;
}

@end
