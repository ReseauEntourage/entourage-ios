//
//  OTMapDelegateProxyBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTMapDelegateBehavior.h"
#import <MapKit/MapKit.h>

@interface OTMapDelegateProxyBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutletCollection(OTMapDelegateBehavior) NSMutableArray *delegates;

@end
