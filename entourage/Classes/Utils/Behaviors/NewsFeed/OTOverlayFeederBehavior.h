//
//  OTOverlayFeederBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMapDelegateBehavior.h"
#import "OTFeedItem.h"

@interface OTOverlayFeederBehavior : OTMapDelegateBehavior

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

- (void)addOverlays:(NSArray *)items;
- (void)updateOverlays:(NSArray *)items;
- (void)updateOverlayFor:(OTFeedItem *)item;

@end
