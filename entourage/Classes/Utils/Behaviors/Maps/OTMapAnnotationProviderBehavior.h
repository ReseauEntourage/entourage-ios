//
//  OTMapAnnotationProviderBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/3/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import <MapKit/MapKit.h>
#import "OTFeedItem.h"

@interface OTMapAnnotationProviderBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet MKMapView *map;

- (void)configureWith:(OTFeedItem *)feedItem;
- (void)addStartPoint;
- (void)drawData;

@end
