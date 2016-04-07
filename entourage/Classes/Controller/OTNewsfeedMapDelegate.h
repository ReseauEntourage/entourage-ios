//
//  OTNewsfeedMapDelegate.h
//  entourage
//
//  Created by Mihai Ionescu on 07/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBaseMapDelegate.h"
#import <MapKit/MapKit.h>

@interface OTNewsfeedMapDelegate : OTBaseMapDelegate <MKMapViewDelegate>

@property (nonatomic, strong) NSMapTable *drawnTours;

@end
