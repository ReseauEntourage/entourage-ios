//
//  OTTapEntourageBehavior.h
//  entourage
//
//  Created by sergiu buceac on 9/11/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import <MapKit/MapKit.h>

@interface OTTapEntourageBehavior : OTBehavior

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKCircle *tappedEntourage;

- (BOOL)hasTappedEntourage:(UITapGestureRecognizer *)recognizer;

@end
