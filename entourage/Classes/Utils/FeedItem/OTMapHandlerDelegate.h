//
//  OTMapHandlerDelegate.h
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol OTMapHandlerDelegate <NSObject>

- (CLLocationCoordinate2D)startPoint;
- (id<MKAnnotation>)annotationFor:(CLLocationCoordinate2D)coordinate;

@end
