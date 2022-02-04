//
//  MKMapView+entourage.h
//  entourage
//
//  Created by Ciprian Habuc on 28/04/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (entourage)

- (void)takeSnapshotToFile:(NSString *)snapshotName;

@end
