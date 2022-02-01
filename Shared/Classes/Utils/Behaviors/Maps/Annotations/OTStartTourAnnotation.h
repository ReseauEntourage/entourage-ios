//
//  OTStartTourAnnotation.h
//  entourage
//
//  Created by sergiu buceac on 11/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "OTTour.h"

extern NSString *const kStartTourAnnotationIdentifier;

@interface OTStartTourAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) OTTour *tour;

- (id)initWithTour:(OTTour *)tour;
- (MKAnnotationView *)annotationView;

@end
