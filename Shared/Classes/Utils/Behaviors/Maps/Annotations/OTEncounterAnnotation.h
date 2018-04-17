//
//  OTEncounterAnnotation.h
//  entourage
//
//  Created by Mathieu Hausherr on 11/10/14.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class OTEncounter;

extern NSString *const kEncounterAnnotationIdentifier;
extern NSString *const kEncounterClusterAnnotationIdentifier;

@interface OTEncounterAnnotation : NSObject <MKAnnotation>

- (id)initWithEncounter:(OTEncounter *)encounter;
- (MKAnnotationView *)annotationView;

@property (nonatomic, strong) OTEncounter *encounter;

@end
