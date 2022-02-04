//
//  OTTapEntourageBehavior.h
//  entourage
//
//  Created by sergiu buceac on 9/11/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"
#import <MapKit/MapKit.h>
#import "OTEntourageAnnotation.h"

@interface OTTapEntourageBehavior : OTBehavior

@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) MKCircle *tappedEntourage;
@property (nonatomic) OTEntourageAnnotation *tappedEntourageAnnotation;

- (NSMutableArray *)hasTappedEntourageOverlay:(UITapGestureRecognizer *)recognizer;
- (NSMutableArray *)hasTappedEntourageAnnotation:(UITapGestureRecognizer *)recognizer;

@end
