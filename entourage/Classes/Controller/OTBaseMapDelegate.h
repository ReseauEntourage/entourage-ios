//
//  OTBaseMapDelegate.h
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OTMainViewController.h"

@interface OTBaseMapDelegate : NSObject

@property (nonatomic, weak) OTMainViewController* mapController;
@property (nonatomic) BOOL isActive;

- (instancetype)initWithMapController:(OTMainViewController *)mapController;

- (CLLocationDistance)mapHeight:(MKMapView *)mapView;

@end
